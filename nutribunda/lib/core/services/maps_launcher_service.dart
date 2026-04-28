import 'package:url_launcher/url_launcher.dart';

/// Service untuk membuat dan membuka deep link Google Maps
/// 
/// Menangani:
/// - Pembuatan deep link URL untuk pencarian fasilitas kesehatan
/// - Membuka Google Maps app atau fallback ke browser
/// - Kategori fasilitas kesehatan yang didukung
/// 
/// **Validates: Requirements 8.3, 8.4, 8.5, 8.6**
class MapsLauncherService {
  /// Kategori fasilitas kesehatan yang didukung
  /// 
  /// Map dari nama kategori (Bahasa Indonesia) ke query search term
  /// **Validates: Requirement 8.3** - Kategori fasilitas kesehatan
  static const Map<String, String> facilityCategories = {
    'Rumah Sakit': 'hospital',
    'Puskesmas': 'puskesmas',
    'Posyandu': 'posyandu',
    'Apotek': 'pharmacy',
  };

  /// Membuat deep link URL untuk Google Maps search
  /// 
  /// Format URL: https://www.google.com/maps/search/?api=1&query={category}+near+{lat},{lng}
  /// 
  /// Parameters:
  /// - [latitude]: Koordinat latitude pengguna
  /// - [longitude]: Koordinat longitude pengguna
  /// - [category]: Kategori fasilitas (hospital, puskesmas, dll)
  /// 
  /// Returns: URL string untuk Google Maps search
  /// 
  /// **Validates: Requirement 8.5** - Format deep link dengan koordinat GPS dan query
  String createMapsSearchUrl({
    required double latitude,
    required double longitude,
    required String category,
  }) {
    // Encode query untuk URL safety
    final query = Uri.encodeComponent('$category near $latitude,$longitude');
    
    // Google Maps Search API URL
    return 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  /// Membuka Google Maps dengan query pencarian fasilitas
  /// 
  /// Mencoba membuka Google Maps app terlebih dahulu, jika tidak tersedia
  /// akan fallback ke browser web.
  /// 
  /// Parameters:
  /// - [latitude]: Koordinat latitude pengguna
  /// - [longitude]: Koordinat longitude pengguna
  /// - [categoryKey]: Key kategori dari facilityCategories map
  /// 
  /// Returns:
  /// - `true` jika berhasil membuka Maps
  /// - `false` jika gagal
  /// 
  /// **Validates: Requirements 8.4, 8.6** - Membuka Google Maps atau browser
  Future<bool> openMapsSearch({
    required double latitude,
    required double longitude,
    required String categoryKey,
  }) async {
    try {
      // Dapatkan nama kategori dalam bahasa Indonesia atau gunakan key langsung
      final category = facilityCategories[categoryKey] ?? categoryKey;
      
      // Buat URL deep link untuk web
      final webUrl = createMapsSearchUrl(
        latitude: latitude,
        longitude: longitude,
        category: category,
      );

      final webUri = Uri.parse(webUrl);

      // Coba buka dengan Google Maps app terlebih dahulu
      // Format: comgooglemaps://?q={category}&center={lat},{lng}
      final googleMapsUri = Uri.parse(
        'comgooglemaps://?q=$category&center=$latitude,$longitude'
      );

      // Cek apakah Google Maps app tersedia
      if (await canLaunchUrl(googleMapsUri)) {
        // Buka di Google Maps app
        await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        // Fallback: buka di browser
        // **Validates: Requirement 8.6** - Fallback ke browser jika Maps tidak terinstall
        if (await canLaunchUrl(webUri)) {
          await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  /// Cek apakah Google Maps app terinstall
  Future<bool> isGoogleMapsInstalled() async {
    try {
      final uri = Uri.parse('comgooglemaps://');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Membuka Google Maps dengan koordinat spesifik (tanpa search)
  /// 
  /// Berguna untuk menampilkan lokasi pengguna di peta
  Future<bool> openMapAtLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Google Maps URL untuk menampilkan lokasi
      final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }
}
