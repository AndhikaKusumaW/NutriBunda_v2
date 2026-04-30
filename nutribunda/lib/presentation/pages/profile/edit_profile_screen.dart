import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/profile_provider.dart';

/// Edit Profile Screen dengan form untuk edit data profil dan upload foto
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5 - Edit profil dan upload foto
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isBreastfeeding = false;
  String _activityLevel = 'sedentary';
  String _timezone = 'WIB';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;

    if (user != null) {
      _nameController.text = user.fullName;
      _weightController.text = user.weight?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _isBreastfeeding = user.isBreastfeeding;
      _activityLevel = user.activityLevel;
      _timezone = user.timezone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }



  /// Save profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileProvider = context.read<ProfileProvider>();

    // Parse input values
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    // Update profile data
    final success = await profileProvider.updateProfile(
      fullName: _nameController.text,
      weight: weight,
      height: height,
      age: age,
      isBreastfeeding: _isBreastfeeding,
      activityLevel: _activityLevel,
      timezone: _timezone,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileProvider.errorMessage ?? 'Gagal memperbarui profil',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Weight Field
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                      helperText: 'Rentang: 30-200 kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      final weight = double.tryParse(value);
                      if (weight == null) {
                        return 'Masukkan angka yang valid';
                      }
                      // Requirements: 12.4 - Validasi berat badan 30-200 kg
                      if (weight < 30 || weight > 200) {
                        return 'Berat badan harus antara 30-200 kg';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Height Field
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Tinggi Badan (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                      helperText: 'Rentang: 100-250 cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      final height = double.tryParse(value);
                      if (height == null) {
                        return 'Masukkan angka yang valid';
                      }
                      // Requirements: 12.4 - Validasi tinggi badan 100-250 cm
                      if (height < 100 || height > 250) {
                        return 'Tinggi badan harus antara 100-250 cm';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Age Field
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Usia (tahun)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                      helperText: 'Rentang: 15-60 tahun',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      final age = int.tryParse(value);
                      if (age == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (age < 15 || age > 60) {
                        return 'Usia harus antara 15-60 tahun';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Breastfeeding Status
                  Card(
                    child: SwitchListTile(
                      title: const Text('Status Menyusui'),
                      subtitle: const Text('Sedang menyusui'),
                      value: _isBreastfeeding,
                      onChanged: (value) {
                        setState(() {
                          _isBreastfeeding = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Activity Level Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _activityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Tingkat Aktivitas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_run),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sedentary',
                        child: Text('Sedentary (Tidak Aktif)'),
                      ),
                      DropdownMenuItem(
                        value: 'lightly_active',
                        child: Text('Lightly Active (Ringan)'),
                      ),
                      DropdownMenuItem(
                        value: 'moderately_active',
                        child: Text('Moderately Active (Sedang)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _activityLevel = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Timezone Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _timezone,
                    decoration: const InputDecoration(
                      labelText: 'Zona Waktu',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'WIB',
                        child: Text('WIB (UTC+7)'),
                      ),
                      DropdownMenuItem(
                        value: 'WITA',
                        child: Text('WITA (UTC+8)'),
                      ),
                      DropdownMenuItem(
                        value: 'WIT',
                        child: Text('WIT (UTC+9)'),
                      ),
                      DropdownMenuItem(
                        value: 'London',
                        child: Text('London (UTC+0/+1)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _timezone = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: profileProvider.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: profileProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
