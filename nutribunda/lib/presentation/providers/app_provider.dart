import 'base_provider.dart';

/// App-level provider untuk manage global app state
/// Seperti theme, locale, connectivity status, dll
class AppProvider extends BaseProvider {
  bool _isDarkMode = false;
  bool _isOnline = true;
  String _locale = 'id';

  /// Getter untuk dark mode status
  bool get isDarkMode => _isDarkMode;

  /// Getter untuk online status
  bool get isOnline => _isOnline;

  /// Getter untuk locale
  String get locale => _locale;

  /// Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    safeNotifyListeners();
  }

  /// Set dark mode
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      safeNotifyListeners();
    }
  }

  /// Update online status
  void updateOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      safeNotifyListeners();
    }
  }

  /// Change locale
  void changeLocale(String newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      safeNotifyListeners();
    }
  }

  /// Initialize app state
  Future<void> initialize() async {
    await executeWithLoading(() async {
      // Load saved preferences
      // Check connectivity
      // Initialize other app-level services
      await Future.delayed(const Duration(seconds: 1)); // Simulate initialization
    });
  }
}
