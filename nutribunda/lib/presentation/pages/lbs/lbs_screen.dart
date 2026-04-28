import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lbs_provider.dart';

/// Screen untuk Location-Based Service (LBS)
/// 
/// Menampilkan:
/// - Status lokasi pengguna saat ini
/// - Grid 4 kategori fasilitas kesehatan
/// - Error handling dan loading states
/// 
/// **Validates: Requirements 8.1-8.7**
class LBSScreen extends StatefulWidget {
  const LBSScreen({super.key});

  @override
  State<LBSScreen> createState() => _LBSScreenState();
}

class _LBSScreenState extends State<LBSScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil lokasi saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LBSProvider>().fetchCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Fasilitas Kesehatan'),
        elevation: 0,
      ),
      body: Consumer<LBSProvider>(
        builder: (context, lbsProvider, child) {
          // Loading state
          if (lbsProvider.isLoadingLocation) {
            return _buildLoadingState();
          }

          // Error state
          if (lbsProvider.errorMessage != null) {
            return _buildErrorState(context, lbsProvider);
          }

          // No location state
          if (lbsProvider.currentPosition == null) {
            return _buildNoLocationState(context, lbsProvider);
          }

          // Success state - show facility categories
          return _buildFacilityCategories(context, lbsProvider);
        },
      ),
    );
  }

  /// Loading state widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Mendapatkan lokasi Anda...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(BuildContext context, LBSProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Show appropriate action button based on error type
            if (provider.errorMessage!.contains('permanen'))
              ElevatedButton.icon(
                onPressed: () {
                  provider.openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Buka Pengaturan'),
              )
            else if (provider.errorMessage!.contains('GPS') ||
                provider.errorMessage!.contains('Layanan lokasi'))
              ElevatedButton.icon(
                onPressed: () {
                  provider.openLocationSettings();
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Aktifkan GPS'),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  provider.fetchCurrentLocation();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
          ],
        ),
      ),
    );
  }

  /// No location state widget
  Widget _buildNoLocationState(BuildContext context, LBSProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Lokasi tidak tersedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan aktifkan layanan lokasi untuk menggunakan fitur ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.fetchCurrentLocation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Main content - facility categories grid
  Widget _buildFacilityCategories(BuildContext context, LBSProvider provider) {
    // Define facility categories with icons and colors
    // **Validates: Requirement 8.3** - 4 kategori fasilitas
    final categories = [
      {
        'key': 'Rumah Sakit',
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
      {
        'key': 'Puskesmas',
        'icon': Icons.medical_services,
        'color': Colors.blue,
      },
      {
        'key': 'Posyandu',
        'icon': Icons.child_care,
        'color': Colors.green,
      },
      {
        'key': 'Apotek',
        'icon': Icons.medication,
        'color': Colors.orange,
      },
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location info card
            _buildLocationInfoCard(provider),
            const SizedBox(height: 24),
            
            // Section title
            const Text(
              'Pilih Fasilitas Kesehatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of facility categories
            // **Validates: Requirement 8.3** - UI dengan 4 kategori dalam grid cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  context,
                  provider,
                  category['key'] as String,
                  category['icon'] as IconData,
                  category['color'] as Color,
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Info text
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  /// Location info card showing current GPS coordinates
  Widget _buildLocationInfoCard(LBSProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.green[600],
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.currentPosition!.latitude.toStringAsFixed(6)}, '
                    '${provider.currentPosition!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                provider.fetchCurrentLocation();
              },
              tooltip: 'Perbarui lokasi',
            ),
          ],
        ),
      ),
    );
  }

  /// Individual facility category card
  /// 
  /// **Validates: Requirements 8.4, 8.5, 8.6** - Membuka Google Maps dengan deep link
  Widget _buildCategoryCard(
    BuildContext context,
    LBSProvider provider,
    String categoryKey,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Show loading indicator
          if (!context.mounted) return;
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          // Search facility
          final success = await provider.searchFacility(categoryKey);

          // Close loading indicator
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Show error if failed
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage ?? 'Gagal membuka Google Maps',
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Tutup',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              categoryKey,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Info text at the bottom
  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ketuk kategori untuk membuka Google Maps dan mencari fasilitas terdekat',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
