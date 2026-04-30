import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'notification_settings_page.dart';
import 'biometric_settings_page.dart';

/// Settings Screen dengan pengaturan aplikasi dan logout
/// Requirements: 13.5 - Menampilkan halaman profil dengan tombol Logout
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // App Settings Section
          _buildSectionHeader('Pengaturan Aplikasi'),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Pengaturan Notifikasi'),
            subtitle: const Text('Atur pengingat makan dan vitamin'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          

          
          // About Section
          _buildSectionHeader('Tentang'),
          
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Versi Aplikasi'),
            subtitle: Text('1.0.0'),
          ),
          
          const Divider(height: 1),
          
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('Tentang NutriBunda'),
            subtitle: Text('Asisten pendamping ibu untuk gizi MPASI'),
          ),
          
          const Divider(height: 1),
          
          // Account Section
          _buildSectionHeader('Akun'),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Keluar dari aplikasi'),
                onTap: () => _showLogoutDialog(context, authProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    // Capture outer context BEFORE the dialog builder shadows it
    final outerContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);

              // Perform logout
              await authProvider.logout();

              // Navigate to login using the outer (settings screen) context
              if (outerContext.mounted) {
                Navigator.of(outerContext).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
