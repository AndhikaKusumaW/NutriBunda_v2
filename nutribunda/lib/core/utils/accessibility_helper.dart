import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper utilities for NutriBunda
/// Task 19.1 - Accessibility labels and semantic widgets
/// 
/// Provides helper methods for:
/// - Creating semantic labels for screen readers
/// - Wrapping widgets with proper semantics
/// - Generating accessible descriptions
class AccessibilityHelper {
  AccessibilityHelper._();

  /// Create semantic label for nutrition value
  /// Example: "Kalori: 500 dari 2000 kalori, 25 persen"
  static String nutritionValueLabel({
    required String nutrientName,
    required double current,
    required double target,
    required String unit,
  }) {
    final percentage = target > 0 ? (current / target * 100).round() : 0;
    return '$nutrientName: ${current.toStringAsFixed(0)} dari ${target.toStringAsFixed(0)} $unit, $percentage persen';
  }

  /// Create semantic label for date
  /// Example: "Tanggal dipilih: Senin, 15 Januari 2024"
  static String dateLabel(DateTime date, {String prefix = 'Tanggal dipilih'}) {
    final weekday = _getIndonesianWeekday(date.weekday);
    final month = _getIndonesianMonth(date.month);
    return '$prefix: $weekday, ${date.day} $month ${date.year}';
  }

  /// Create semantic label for meal time
  static String mealTimeLabel(String mealTime) {
    final labels = {
      'breakfast': 'Makan Pagi',
      'lunch': 'Makan Siang',
      'dinner': 'Makan Malam',
      'snack': 'Makanan Selingan',
    };
    return labels[mealTime] ?? mealTime;
  }

  /// Create semantic label for profile type
  static String profileTypeLabel(String profileType) {
    return profileType == 'baby' ? 'Profil Bayi' : 'Profil Ibu';
  }

  /// Create semantic label for button with icon
  static String iconButtonLabel(String action, {String? context}) {
    if (context != null) {
      return '$action $context';
    }
    return action;
  }

  /// Create semantic label for progress indicator
  static String progressLabel({
    required String item,
    required double current,
    required double total,
  }) {
    final percentage = total > 0 ? (current / total * 100).round() : 0;
    return '$item: $percentage persen selesai';
  }

  /// Create semantic label for navigation tab
  static String navigationTabLabel({
    required String tabName,
    required int index,
    required int total,
    required bool isSelected,
  }) {
    final status = isSelected ? 'dipilih' : 'tidak dipilih';
    return '$tabName, tab ${index + 1} dari $total, $status';
  }

  /// Create semantic label for list item
  static String listItemLabel({
    required String itemName,
    required int index,
    required int total,
  }) {
    return '$itemName, item ${index + 1} dari $total';
  }

  /// Create semantic label for food entry
  static String foodEntryLabel({
    required String foodName,
    required double servingSize,
    required String mealTime,
    required double calories,
  }) {
    final mealLabel = mealTimeLabel(mealTime);
    return '$foodName, ${servingSize.toStringAsFixed(0)} gram, $mealLabel, ${calories.toStringAsFixed(0)} kalori';
  }

  /// Create semantic label for BMR/TDEE values
  static String metabolicRateLabel({
    required String type,
    required double value,
  }) {
    final typeLabel = type == 'BMR' ? 'Metabolisme Basal' : 'Total Energi Harian';
    return '$typeLabel: ${value.toStringAsFixed(0)} kalori';
  }

  /// Create semantic label for step count
  static String stepCountLabel(int steps, double caloriesBurned) {
    return '$steps langkah, membakar ${caloriesBurned.toStringAsFixed(0)} kalori';
  }

  /// Create semantic label for quiz score
  static String quizScoreLabel({
    required int score,
    required int total,
  }) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    return 'Skor: $score dari $total, $percentage persen benar';
  }

  /// Create semantic label for notification time
  static String notificationTimeLabel({
    required String type,
    required String time,
    required bool isActive,
  }) {
    final status = isActive ? 'aktif' : 'nonaktif';
    return 'Notifikasi $type pada pukul $time, status $status';
  }

  /// Wrap widget with semantic label
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? link,
    bool? image,
    bool? textField,
    bool? focusable,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      image: image,
      textField: textField,
      focusable: focusable ?? true,
      enabled: enabled ?? true,
      onTap: onTap,
      onLongPress: onLongPress,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Exclude widget from semantics tree (for decorative elements)
  static Widget excludeSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  /// Merge semantics for complex widgets
  static Widget mergeSemantics({
    required Widget child,
    bool merge = true,
  }) {
    return MergeSemantics(child: child);
  }

  /// Create accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: Card(
        margin: margin,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// Create accessible icon button
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String? hint,
    Color? color,
    double? size,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: true,
      child: IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        color: color,
        tooltip: label,
      ),
    );
  }

  /// Create accessible image with semantic label
  static Widget accessibleImage({
    required ImageProvider image,
    required String label,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      label: label,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: label,
      ),
    );
  }

  /// Helper: Get Indonesian weekday name
  static String _getIndonesianWeekday(int weekday) {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return weekdays[weekday - 1];
  }

  /// Helper: Get Indonesian month name
  static String _getIndonesianMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create semantic hint for interactive elements
  static String getInteractionHint(String action) {
    return 'Ketuk dua kali untuk $action';
  }

  /// Create semantic label for loading state
  static String loadingLabel(String context) {
    return 'Memuat $context, mohon tunggu';
  }

  /// Create semantic label for error state
  static String errorLabel(String context, String error) {
    return 'Terjadi kesalahan saat memuat $context: $error';
  }

  /// Create semantic label for empty state
  static String emptyStateLabel(String context) {
    return 'Tidak ada $context yang tersedia';
  }
}
