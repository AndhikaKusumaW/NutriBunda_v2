import 'package:geolocator/geolocator.dart';

/// Service untuk mengelola akses lokasi GPS pengguna
/// 
/// Menangani:
/// - Permission handling untuk akses lokasi
/// - Mendapatkan koordinat GPS pengguna saat ini
/// - Error handling untuk berbagai skenario lokasi
/// 
/// **Validates: Requirements 8.1, 8.2**
class LocationService {
  /// Memeriksa dan meminta izin lokasi dari pengguna
  /// 
  /// Returns:
  /// - `true` jika izin lokasi diberikan
  /// - `false` jika izin ditolak atau layanan lokasi tidak aktif
  /// 
  /// **Validates: Requirement 8.1** - Meminta izin akses lokasi perangkat
  Future<bool> requestLocationPermission() async {
    // Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak aktif (GPS dimatikan)
      return false;
    }

    // Cek status permission saat ini
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Minta izin lokasi
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak oleh pengguna
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak secara permanen, harus ke settings
      return false;
    }

    // Izin diberikan (whileInUse atau always)
    return true;
  }

  /// Mendapatkan koordinat GPS pengguna saat ini
  /// 
  /// Returns:
  /// - `Position` object berisi latitude dan longitude jika berhasil
  /// - `null` jika gagal mendapatkan lokasi atau izin tidak diberikan
  /// 
  /// **Validates: Requirement 8.2** - Mendapatkan koordinat GPS menggunakan geolocator
  Future<Position?> getCurrentLocation() async {
    try {
      // Pastikan izin lokasi sudah diberikan
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Dapatkan posisi saat ini dengan akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return position;
    } catch (e) {
      // Error bisa terjadi karena timeout, GPS tidak tersedia, dll
      // In production, use proper logging instead of print
      return null;
    }
  }

  /// Cek apakah layanan lokasi aktif di perangkat
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Cek status permission lokasi saat ini tanpa meminta
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Buka pengaturan lokasi perangkat
  /// 
  /// Berguna ketika izin ditolak secara permanen (deniedForever)
  /// **Validates: Requirement 8.7** - Mengarahkan ke pengaturan perangkat
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Buka pengaturan aplikasi untuk mengubah permission
  /// 
  /// **Validates: Requirement 8.7** - Mengarahkan ke pengaturan perangkat
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
