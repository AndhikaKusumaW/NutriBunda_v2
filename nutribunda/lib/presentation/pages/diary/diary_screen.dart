import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/food_diary_provider.dart';
import '../../widgets/diary/nutrition_summary_card.dart';
import '../../widgets/diary/diary_entry_card.dart';
import 'add_diary_entry_screen.dart';

/// Diary Screen - Main screen untuk Food Diary
/// Requirements: 4.1, 4.4, 4.6 - Dual profile, meal time slots, nutrition summary
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodDiaryProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final provider = context.read<FoodDiaryProvider>();
      final newProfile = _tabController.index == 0 ? 'baby' : 'mother';
      provider.setSelectedProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar dengan TabBar
        Container(
          color: Theme.of(context).colorScheme.primary,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      Text(
                        'Food Diary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Bayi', icon: Icon(Icons.child_care)),
                    Tab(text: 'Ibu', icon: Icon(Icons.person)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Body
        Expanded(
          child: Stack(
            children: [
              Consumer<FoodDiaryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              provider.clearError();
                              provider.loadEntries();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadEntries(),
                    child: CustomScrollView(
                      slivers: [
                        // Date Picker
                        SliverToBoxAdapter(
                          child: _buildDatePicker(context, provider),
                        ),

                        // Nutrition Summary Card
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: NutritionSummaryCard(
                              summary: provider.nutritionSummary,
                              profileType: provider.selectedProfile,
                            ),
                          ),
                        ),

                        // Diary Entries by Meal Time
                        ..._buildMealTimeSections(context, provider),

                        // Empty state
                        if (provider.entries.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada catatan makanan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap tombol + untuk menambah',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bottom padding for FAB and bottom nav
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 160),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // FloatingActionButton positioned manually
              Positioned(
                right: 16,
                bottom: 80, // Above bottom navigation bar
                child: FloatingActionButton(
                  onPressed: () => _navigateToAddEntry(context),
                  tooltip: 'Tambah Makanan',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, FoodDiaryProvider provider) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = provider.selectedDate.subtract(const Duration(days: 1));
              provider.setSelectedDate(newDate);
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(provider.selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = provider.selectedDate.add(const Duration(days: 1));
              // Don't allow future dates
              if (newDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                provider.setSelectedDate(newDate);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, FoodDiaryProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  List<Widget> _buildMealTimeSections(BuildContext context, FoodDiaryProvider provider) {
    final entriesByMealTime = provider.entriesByMealTime;
    final mealTimes = [
      {'key': 'breakfast', 'label': 'Makan Pagi', 'icon': Icons.wb_sunny},
      {'key': 'lunch', 'label': 'Makan Siang', 'icon': Icons.wb_sunny_outlined},
      {'key': 'dinner', 'label': 'Makan Malam', 'icon': Icons.nightlight},
      {'key': 'snack', 'label': 'Makanan Selingan', 'icon': Icons.cookie},
    ];

    List<Widget> sections = [];

    for (final mealTime in mealTimes) {
      final entries = entriesByMealTime[mealTime['key']] ?? [];

      if (entries.isNotEmpty) {
        // Section header
        sections.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(
                    mealTime['icon'] as IconData,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mealTime['label'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Entries
        sections.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DiaryEntryCard(
                    entry: entry,
                    onDelete: () => _confirmDelete(context, provider, entry.id),
                  ),
                );
              },
              childCount: entries.length,
            ),
          ),
        );
      }
    }

    return sections;
  }

  Future<void> _confirmDelete(BuildContext context, FoodDiaryProvider provider, String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Entri'),
        content: const Text('Apakah Anda yakin ingin menghapus entri ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteEntry(entryId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menghapus entri'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddEntry(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddDiaryEntryScreen(),
      ),
    );

    if (result == true && context.mounted) {
      // Reload entries after adding
      context.read<FoodDiaryProvider>().loadEntries();
    }
  }
}
