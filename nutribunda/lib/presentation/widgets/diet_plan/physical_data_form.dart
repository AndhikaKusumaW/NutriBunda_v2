import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diet_plan_provider.dart';

/// Physical Data Form Widget
/// Requirements: 5.11 - Form untuk input data fisik pengguna
class PhysicalDataForm extends StatefulWidget {
  final VoidCallback? onSaved;

  const PhysicalDataForm({
    super.key,
    this.onSaved,
  });

  @override
  State<PhysicalDataForm> createState() => _PhysicalDataFormState();
}

class _PhysicalDataFormState extends State<PhysicalDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _activityLevel = 'sedentary';
  bool _isBreastfeeding = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        if (user.weight != null) {
          _weightController.text = user.weight!.toStringAsFixed(1);
        }
        if (user.height != null) {
          _heightController.text = user.height!.toStringAsFixed(1);
        }
        if (user.age != null) {
          _ageController.text = user.age.toString();
        }
        _activityLevel = user.activityLevel;
        _isBreastfeeding = user.isBreastfeeding;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Data Fisik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Weight input
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Contoh: 60.5',
                  prefixIcon: const Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat badan harus diisi';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (weight < 30 || weight > 200) {
                    return 'Berat badan harus antara 30-200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Height input
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  hintText: 'Contoh: 165',
                  prefixIcon: const Icon(Icons.height),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tinggi badan harus diisi';
                  }
                  final height = double.tryParse(value);
                  if (height == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (height < 100 || height > 250) {
                    return 'Tinggi badan harus antara 100-250 cm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age input
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Usia (tahun)',
                  hintText: 'Contoh: 30',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Usia harus diisi';
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
              const SizedBox(height: 20),

              // Activity level dropdown
              DropdownButtonFormField<String>(
                initialValue: _activityLevel,
                decoration: InputDecoration(
                  labelText: 'Tingkat Aktivitas',
                  prefixIcon: const Icon(Icons.directions_run),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'sedentary',
                    child: Text('Sedentary (Jarang bergerak)'),
                  ),
                  DropdownMenuItem(
                    value: 'lightly_active',
                    child: Text('Lightly Active (Olahraga ringan 1-3x/minggu)'),
                  ),
                  DropdownMenuItem(
                    value: 'moderately_active',
                    child: Text('Moderately Active (Olahraga 3-5x/minggu)'),
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
              const SizedBox(height: 20),

              // Breastfeeding checkbox
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  title: const Text('Sedang Menyusui'),
                  subtitle: const Text(
                    'Akan menambahkan 400 kkal ke target harian',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isBreastfeeding,
                  onChanged: (value) {
                    setState(() {
                      _isBreastfeeding = value ?? false;
                    });
                  },
                  secondary: const Icon(Icons.child_care),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final dietPlanProvider = context.read<DietPlanProvider>();

      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final age = int.parse(_ageController.text);

      // Update user profile
      final success = await authProvider.updateProfile(
        weight: weight,
        height: height,
        age: age,
        activityLevel: _activityLevel,
        isBreastfeeding: _isBreastfeeding,
      );

      if (success) {
        // Update diet plan provider
        dietPlanProvider.updateUserProfile(
          weight: weight,
          height: height,
          age: age,
          activityLevel: _activityLevel,
          isBreastfeeding: _isBreastfeeding,
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Gagal menyimpan data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
