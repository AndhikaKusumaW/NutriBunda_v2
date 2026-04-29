import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import '../settings/settings_screen.dart';

/// Profile screen dengan informasi pengguna dan tombol logout
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 13.5 - Profil pengguna dan logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading && profileProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profileProvider.errorMessage != null && profileProvider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(profileProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.fetchProfile();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final user = profileProvider.user;

          if (user == null) {
            return const Center(
              child: Text('Data pengguna tidak tersedia'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => profileProvider.fetchProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(context, user),

                  const SizedBox(height: 24),

                  // Profile Information
                  _buildProfileInfo(context, user),

                  const SizedBox(height: 24),

                  // Edit Profile Button
                  _buildEditProfileButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Name and Email
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              'Berat Badan',
              user.weight != null ? '${user.weight} kg' : 'Belum diisi',
            ),
            _buildInfoRow(
              'Tinggi Badan',
              user.height != null ? '${user.height} cm' : 'Belum diisi',
            ),
            _buildInfoRow(
              'Usia',
              user.age != null ? '${user.age} tahun' : 'Belum diisi',
            ),
            _buildInfoRow(
              'Status Menyusui',
              user.isBreastfeeding ? 'Ya' : 'Tidak',
            ),
            _buildInfoRow(
              'Tingkat Aktivitas',
              _getActivityLevelText(user.activityLevel),
            ),
            _buildInfoRow('Zona Waktu', user.timezone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profil'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _getActivityLevelText(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 'Tidak Aktif';
      case 'lightly_active':
        return 'Ringan';
      case 'moderately_active':
        return 'Sedang';
      default:
        return 'Tidak Aktif';
    }
  }
}