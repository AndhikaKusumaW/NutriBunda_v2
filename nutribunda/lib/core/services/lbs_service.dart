import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LbsService {
  /// Minta izin & dapatkan posisi saat ini.
  /// Return [Position] jika berhasil, atau null jika ditolak/error.
  Future<Position?> getCurrentPosition() async {
    // Cek apakah location service aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Cek dan minta permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Dapatkan posisi dengan akurasi tinggi
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }

  /// Cek apakah location service aktif.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Cek status permission tanpa memintanya.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Buka Google Maps dengan query fasilitas kesehatan terdekat (puskesmas).
  /// Gunakan url_launcher untuk membuka:
  /// "https://www.google.com/maps/search/puskesmas+terdekat/@{lat},{lng},15z"
  Future<void> openNearbyHealthFacilities(double lat, double lng) async {
    await openNearbyByType(lat, lng, 'puskesmas terdekat');
  }

  /// Buka Google Maps dengan query spesifik (rumah sakit, apotek, dll.)
  /// [type] contoh: 'rumah sakit', 'apotek', 'puskesmas terdekat'
  Future<void> openNearbyByType(
      double lat, double lng, String type) async {
    final query = Uri.encodeComponent(type);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/$query/@$lat,$lng,15z',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: buka dengan geo URI scheme (intent Android)
      final geoUri = Uri.parse('geo:$lat,$lng?q=$query');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
