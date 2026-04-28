import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../core/services/maps_launcher_service.dart';

/// Provider untuk Location-Based Service (LBS)
/// 
/// Mengelola state untuk:
/// - Lokasi GPS pengguna saat ini
/// - Loading state saat mengambil lokasi
/// - Error handling untuk berbagai skenario
/// - Integrasi dengan LocationService dan MapsLauncherService
/// 
/// **Validates: Requirements 8.1-8.7**
class LBSProvider extends ChangeNotifier {
  final LocationService _locationService;
  final MapsLauncherService _mapsLauncher;

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _errorMessage;
  LocationPermission? _permissionStatus;

  LBSProvider({
    LocationService? locationService,
    MapsLauncherService? mapsLauncher,
  })  : _locationService = locationService ?? LocationService(),
        _mapsLauncher = mapsLauncher ?? MapsLauncherService();

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get errorMessage => _errorMessage;
  LocationPermission? get permissionStatus => _permissionStatus;
  bool get hasLocation => _currentPosition != null;

  /// Mendapatkan lokasi pengguna saat ini
  /// 
  /// Menangani:
  /// - Request permission jika belum diberikan
  /// - Mendapatkan koordinat GPS
  /// - Error handling untuk berbagai skenario
  /// 
  /// **Validates: Requirements 8.1, 8.2, 8.7**
  Future<void> fetchCurrentLocation() async {
    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cek status permission terlebih dahulu
      _permissionStatus = await _locationService.checkPermission();

      // Cek apakah layanan lokasi aktif
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 
            'Layanan lokasi tidak aktif. Silakan aktifkan GPS di pengaturan perangkat Anda.';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      // Dapatkan lokasi
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        _currentPosition = position;
        _errorMessage = null;
      } else {
        // Tentukan pesan error berdasarkan permission status
        if (_permissionStatus == LocationPermission.deniedForever) {
          _errorMessage = 
              'Izin lokasi ditolak secara permanen. Silakan aktifkan izin lokasi di pengaturan aplikasi.';
        } else if (_permissionStatus == LocationPermission.denied) {
          _errorMessage = 
              'Izin lokasi diperlukan untuk menggunakan fitur ini. Silakan berikan izin lokasi.';
        } else {
          _errorMessage = 
              'Tidak dapat mengakses lokasi. Pastikan GPS aktif dan sinyal tersedia.';
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mengambil lokasi: ${e.toString()}';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Membuka pencarian fasilitas kesehatan di Google Maps
  /// 
  /// Parameters:
  /// - [categoryKey]: Key kategori dari MapsLauncherService.facilityCategories
  /// 
  /// Returns:
  /// - `true` jika berhasil membuka Maps
  /// - `false` jika gagal
  /// 
  /// **Validates: Requirements 8.3, 8.4, 8.5, 8.6**
  Future<bool> searchFacility(String categoryKey) async {
    // Validasi lokasi tersedia
    if (_currentPosition == null) {
      _errorMessage = 'Lokasi belum tersedia. Silakan coba lagi.';
      notifyListeners();
      return false;
    }

    try {
      // Buka Google Maps dengan query pencarian
      final success = await _mapsLauncher.openMapsSearch(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        categoryKey: categoryKey,
      );

      if (!success) {
        _errorMessage = 
            'Tidak dapat membuka Google Maps. Pastikan aplikasi terinstall atau browser tersedia.';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Membuka pengaturan lokasi perangkat
  /// 
  /// Berguna ketika layanan lokasi tidak aktif
  /// **Validates: Requirement 8.7**
  Future<void> openLocationSettings() async {
    try {
      await _locationService.openLocationSettings();
    } catch (e) {
      _errorMessage = 'Tidak dapat membuka pengaturan lokasi';
      notifyListeners();
    }
  }

  /// Membuka pengaturan aplikasi
  /// 
  /// Berguna ketika izin lokasi ditolak secara permanen
  /// **Validates: Requirement 8.7**
  Future<void> openAppSettings() async {
    try {
      await _locationService.openAppSettings();
    } catch (e) {
      _errorMessage = 'Tidak dapat membuka pengaturan aplikasi';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _currentPosition = null;
    _isLoadingLocation = false;
    _errorMessage = null;
    _permissionStatus = null;
    notifyListeners();
  }

  /// Cek apakah Google Maps terinstall
  Future<bool> isGoogleMapsInstalled() async {
    return await _mapsLauncher.isGoogleMapsInstalled();
  }
}
