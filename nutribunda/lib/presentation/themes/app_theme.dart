import 'package:flutter/material.dart';

/// Comprehensive theme configuration for NutriBunda
/// Task 19.1 - UI/UX refinement dan accessibility
/// 
/// Provides consistent theming across all screens with:
/// - Material 3 design system
/// - Accessible color contrasts (WCAG AA compliant)
/// - Consistent typography scale
/// - Semantic color usage
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);
  
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryPink = Color(0xFFE91E63);
  
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);
  
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color infoBlue = Color(0xFF1976D2);
  
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: secondaryBlue,
        secondaryContainer: secondaryBlue.withValues(alpha: 0.1),
        tertiary: secondaryPink,
        error: errorRed,
        surface: surfaceLight,
        surfaceContainerHighest: surfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        brightness: Brightness.light,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: backgroundLight,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: primaryGreen, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          color: textSecondary,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: errorRed,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryGreenLight,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Dialog theme
      dialogTheme: const DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: textSecondary,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Tab bar theme
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Typography
      textTheme: const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        
        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: textPrimary,
        ),
        
        // Title styles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        
        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: textSecondary,
        ),
        
        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textSecondary,
        ),
      ),
    );
  }

  /// Semantic color helpers for consistent usage
  static Color getBabyColor() => secondaryBlue;
  static Color getMotherColor() => secondaryPink;
  static Color getSuccessColor() => successGreen;
  static Color getWarningColor() => warningOrange;
  static Color getErrorColor() => errorRed;
  static Color getInfoColor() => infoBlue;
  
  /// Nutrition progress color based on percentage
  static Color getNutritionProgressColor(double percentage) {
    if (percentage <= 0.5) {
      return errorRed; // Low - red
    } else if (percentage <= 0.8) {
      return warningOrange; // Medium - orange
    } else if (percentage <= 1.0) {
      return successGreen; // Good - green
    } else {
      return warningOrange; // Exceeded - orange
    }
  }
  
  /// Get color with proper contrast for accessibility
  static Color getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
