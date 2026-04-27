import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Halaman pengaturan biometric authentication
/// Requirements: 2.1, 2.3, 2.5 - UI untuk enable/disable biometric auth
class BiometricSettingsPage extends StatefulWidget {
  const BiometricSettingsPage({super.key});

  @override
  State<BiometricSettingsPage> createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends State<BiometricSettingsPage> {
  bool _isLoading = true;
  bool _isBiometricEnabled = false;
  bool _isDeviceSupported = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String _biometricTypeDescription = 'Biometrik';
  String? _errorMessage;

  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Cek status biometric di perangkat
  Future<void> _checkBiometricStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final biometricService = authProvider.biometricService;

      // Cek device support
      final isSupported = await biometricService.isDeviceSupported();
      final isAvailable = await biometricService.isBiometricAvailable();
      final isEnabled = await biometricService.isBiometricEnabled();
      final availableBiometrics = await biometricService.getAvailableBiometrics();
      final description = biometricService.getBiometricTypeDescription(availableBiometrics);

      setState(() {
        _isDeviceSupported = isSupported;
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _availableBiometrics = availableBiometrics;
        _biometricTypeDescription = description;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memeriksa status biometrik: $e';
        _isLoading = false;
      });
    }
  }

  /// Toggle biometric authentication
  Future<void> _toggleBiometric(bool value) async {
    final authProvider = context.read<AuthProvider>();
    final biometricService = authProvider.biometricService;

    if (value) {
      // Enable biometric - Requirements: 2.5 - Meminta konfirmasi password
      await _showPasswordConfirmationDialog();
    } else {
      // Disable biometric
      await biometricService.disableBiometric();
      setState(() {
        _isBiometricEnabled = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autentikasi biometrik dinonaktifkan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Show password confirmation dialog
  /// Requirements: 2.5 - Meminta konfirmasi password sebelum mengaktifkan
  Future<void> _showPasswordConfirmationDialog() async {
    _passwordController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Untuk keamanan, masukkan password Anda untuk mengaktifkan autentikasi biometrik.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = _passwordController.text;
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Verify password dengan backend
              final isValid = await _verifyPassword(password);
              if (isValid && mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Password verified, enable biometric
      final authProvider = context.read<AuthProvider>();
      final biometricService = authProvider.biometricService;

      await biometricService.enableBiometric();
      setState(() {
        _isBiometricEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Autentikasi $_biometricTypeDescription diaktifkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Verify password dengan login ke backend
  Future<bool> _verifyPassword(String password) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null || user.email.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pengguna tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // Try login dengan email dan password untuk verify
      // Note: Ini akan membuat token baru, tapi tidak masalah karena kita sudah login
      final success = await authProvider.login(user.email, password);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return success;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memverifikasi password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Test biometric authentication
  Future<void> _testBiometric() async {
    final authProvider = context.read<AuthProvider>();
    final biometricService = authProvider.biometricService;

    final result = await biometricService.authenticate(
      localizedReason: 'Test autentikasi $_biometricTypeDescription',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Biometrik'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 24),

                  // Requirements: 2.3 - Menampilkan status device capability
                  if (!_isDeviceSupported) ...[
                    _buildNotSupportedCard(),
                  ] else if (!_isBiometricAvailable) ...[
                    _buildNotEnrolledCard(),
                  ] else ...[
                    // Biometric Toggle
                    _buildBiometricToggle(),
                    const SizedBox(height: 16),

                    // Test Button
                    if (_isBiometricEnabled) ...[
                      _buildTestButton(),
                      const SizedBox(height: 16),
                    ],

                    // Info Card
                    _buildInfoCard(),
                  ],

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isBiometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
                  size: 32,
                  color: _isBiometricEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _biometricTypeDescription,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isBiometricEnabled ? 'Aktif' : 'Tidak Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isBiometricEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Perangkat Mendukung',
              _isDeviceSupported,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Biometrik Terdaftar',
              _isBiometricAvailable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Row(
      children: [
        Icon(
          status ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: status ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNotSupportedCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Perangkat Anda tidak mendukung autentikasi biometrik.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotEnrolledCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tidak ada biometrik yang terdaftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Untuk menggunakan autentikasi biometrik, silakan daftarkan sidik jari atau Face ID di pengaturan perangkat Anda terlebih dahulu.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricToggle() {
    return Card(
      child: SwitchListTile(
        title: Text('Aktifkan $_biometricTypeDescription'),
        subtitle: Text(
          _isBiometricEnabled
              ? 'Gunakan $_biometricTypeDescription untuk login'
              : 'Login dengan $_biometricTypeDescription dinonaktifkan',
        ),
        value: _isBiometricEnabled,
        onChanged: _toggleBiometric,
        secondary: Icon(
          _isBiometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
          color: _isBiometricEnabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _testBiometric,
        icon: const Icon(Icons.fingerprint),
        label: Text('Test $_biometricTypeDescription'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Informasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Autentikasi biometrik memungkinkan Anda login dengan cepat menggunakan sidik jari atau Face ID.\n\n'
              '• Untuk keamanan, Anda perlu memasukkan password saat mengaktifkan fitur ini.\n\n'
              '• Setelah 3 kali percobaan gagal, autentikasi biometrik akan dinonaktifkan sementara selama 5 menit.\n\n'
              '• Anda tetap dapat login menggunakan email dan password kapan saja.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
