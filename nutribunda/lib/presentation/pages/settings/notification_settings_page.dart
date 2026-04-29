import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

/// Halaman pengaturan notifikasi
/// Menangani UI untuk manage notification settings sesuai Requirements 11.1-11.6
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationProvider>().initialize();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat pengaturan notifikasi...'),
                ],
              ),
            );
          }

          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Terjadi kesalahan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.initialize();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permission status card
                _buildPermissionCard(context, provider),
                const SizedBox(height: 16),

                // Timezone selection
                _buildTimezoneSection(context, provider),
                const SizedBox(height: 16),

                // MPASI notifications section
                _buildMpasiSection(context, provider),
                const SizedBox(height: 16),

                // Vitamin notifications section
                _buildVitaminSection(context, provider),
                const SizedBox(height: 16),

                // Summary card
                _buildSummaryCard(context, provider),
                const SizedBox(height: 16),

                // Action buttons
                _buildActionButtons(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, NotificationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.permissionGranted ? Icons.check_circle : Icons.warning,
                  color: provider.permissionGranted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status Izin Notifikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.permissionGranted
                  ? 'Izin notifikasi telah diberikan'
                  : 'Izin notifikasi belum diberikan',
              style: TextStyle(
                color: provider.permissionGranted ? Colors.green : Colors.orange,
              ),
            ),
            if (!provider.permissionGranted) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final granted = await provider.requestPermissions();
                        if (!granted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Izin notifikasi diperlukan untuk menggunakan fitur pengingat. '
                                'Silakan aktifkan di pengaturan perangkat.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.notifications),
                label: const Text('Minta Izin Notifikasi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneSection(BuildContext context, NotificationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zona Waktu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih zona waktu untuk penjadwalan notifikasi',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...provider.timezoneOptions.map((timezone) {
              return RadioListTile<String>(
                title: Text(timezone),
                subtitle: Text(provider.timezoneDescriptions[timezone] ?? ''),
                value: timezone,
                groupValue: provider.timezone,
                onChanged: provider.permissionGranted && !provider.isLoading
                    ? (value) {
                        if (value != null) {
                          provider.changeTimezone(value);
                        }
                      }
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMpasiSection(BuildContext context, NotificationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.baby_changing_station, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Pengingat MPASI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pengingat jadwal makan MPASI untuk bayi',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aktifkan Pengingat MPASI'),
              subtitle: const Text('Pengingat otomatis untuk jadwal makan bayi'),
              value: provider.mpasiEnabled,
              onChanged: provider.permissionGranted && !provider.isLoading
                  ? provider.toggleMpasiNotifications
                  : null,
            ),
            if (provider.mpasiEnabled) ...[
              const Divider(),
              const Text(
                'Jadwal Makan:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...List.generate(provider.mealNames.length, (index) {
                return CheckboxListTile(
                  title: Text(provider.mealNames[index]),
                  value: provider.mpasiMeals[index],
                  onChanged: provider.permissionGranted && !provider.isLoading
                      ? (value) {
                          if (value != null) {
                            provider.toggleMpasiMeal(index, value);
                          }
                        }
                      : null,
                  dense: true,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitaminSection(BuildContext context, NotificationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Pengingat Vitamin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pengingat minum vitamin untuk ibu',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aktifkan Pengingat Vitamin'),
              subtitle: const Text('Pengingat harian untuk minum vitamin'),
              value: provider.vitaminEnabled,
              onChanged: provider.permissionGranted && !provider.isLoading
                  ? provider.toggleVitaminNotifications
                  : null,
            ),
            if (provider.vitaminEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('Waktu Pengingat'),
                subtitle: Text('Saat ini: ${provider.vitaminTime}'),
                trailing: const Icon(Icons.access_time),
                onTap: provider.permissionGranted && !provider.isLoading
                    ? () => _showTimePicker(context, provider)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, NotificationProvider provider) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(provider.getNotificationSummary()),
            if (provider.permissionGranted) ...[
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: provider.getPendingNotificationsCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Notifikasi terjadwal: ${snapshot.data}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, NotificationProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => _showResetDialog(context, provider),
            icon: const Icon(Icons.restore),
            label: const Text('Reset ke Pengaturan Default'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => _showCancelAllDialog(context, provider),
            icon: const Icon(Icons.notifications_off),
            label: const Text('Batalkan Semua Notifikasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[300],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker(BuildContext context, NotificationProvider provider) async {
    final currentTime = TimeOfDay(
      hour: int.parse(provider.vitaminTime.split(':')[0]),
      minute: int.parse(provider.vitaminTime.split(':')[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.setVitaminTime(timeString);
    }
  }

  Future<void> _showResetDialog(BuildContext context, NotificationProvider provider) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text(
          'Apakah Anda yakin ingin mengembalikan semua pengaturan notifikasi ke default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan telah direset ke default'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showCancelAllDialog(BuildContext context, NotificationProvider provider) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Semua Notifikasi'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan semua notifikasi yang aktif?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Batalkan Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.cancelAllNotifications();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi telah dibatalkan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}