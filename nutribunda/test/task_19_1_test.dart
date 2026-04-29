import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/presentation/themes/app_theme.dart';
import 'package:nutribunda/core/utils/accessibility_helper.dart';
import 'package:nutribunda/core/services/analytics_service.dart';

/// Tests for Task 19.1: UI/UX Refinement and Accessibility
/// 
/// Tests cover:
/// 1. Theme configuration
/// 2. Accessibility helper methods
/// 3. Analytics service functionality
void main() {
  group('Task 19.1 - UI/UX Refinement and Accessibility', () {
    group('AppTheme', () {
      test('lightTheme should be properly configured', () {
        final theme = AppTheme.lightTheme;
        
        expect(theme.useMaterial3, true);
        expect(theme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, AppTheme.primaryGreen);
      });

      test('semantic color helpers should return correct colors', () {
        expect(AppTheme.getBabyColor(), AppTheme.secondaryBlue);
        expect(AppTheme.getMotherColor(), AppTheme.secondaryPink);
        expect(AppTheme.getSuccessColor(), AppTheme.successGreen);
        expect(AppTheme.getWarningColor(), AppTheme.warningOrange);
        expect(AppTheme.getErrorColor(), AppTheme.errorRed);
        expect(AppTheme.getInfoColor(), AppTheme.infoBlue);
      });

      test('nutrition progress color should vary by percentage', () {
        // Low (0-50%) - Red
        expect(AppTheme.getNutritionProgressColor(0.3), AppTheme.errorRed);
        
        // Medium (50-80%) - Orange
        expect(AppTheme.getNutritionProgressColor(0.6), AppTheme.warningOrange);
        
        // Good (80-100%) - Green
        expect(AppTheme.getNutritionProgressColor(0.9), AppTheme.successGreen);
        
        // Exceeded (>100%) - Orange
        expect(AppTheme.getNutritionProgressColor(1.2), AppTheme.warningOrange);
      });
    });

    group('AccessibilityHelper', () {
      test('nutritionValueLabel should format correctly', () {
        final label = AccessibilityHelper.nutritionValueLabel(
          nutrientName: 'Kalori',
          current: 500,
          target: 2000,
          unit: 'kalori',
        );
        
        expect(label, contains('Kalori'));
        expect(label, contains('500'));
        expect(label, contains('2000'));
        expect(label, contains('kalori'));
        expect(label, contains('25 persen'));
      });

      test('dateLabel should format in Indonesian', () {
        final date = DateTime(2024, 1, 15); // Monday
        final label = AccessibilityHelper.dateLabel(date);
        
        expect(label, contains('Senin'));
        expect(label, contains('15'));
        expect(label, contains('Januari'));
        expect(label, contains('2024'));
      });

      test('mealTimeLabel should return Indonesian labels', () {
        expect(
          AccessibilityHelper.mealTimeLabel('breakfast'),
          'Makan Pagi',
        );
        expect(
          AccessibilityHelper.mealTimeLabel('lunch'),
          'Makan Siang',
        );
        expect(
          AccessibilityHelper.mealTimeLabel('dinner'),
          'Makan Malam',
        );
        expect(
          AccessibilityHelper.mealTimeLabel('snack'),
          'Makanan Selingan',
        );
      });

      test('profileTypeLabel should return correct labels', () {
        expect(
          AccessibilityHelper.profileTypeLabel('baby'),
          'Profil Bayi',
        );
        expect(
          AccessibilityHelper.profileTypeLabel('mother'),
          'Profil Ibu',
        );
      });

      test('navigationTabLabel should include position and status', () {
        final label = AccessibilityHelper.navigationTabLabel(
          tabName: 'Home',
          index: 0,
          total: 4,
          isSelected: true,
        );
        
        expect(label, contains('Home'));
        expect(label, contains('tab 1 dari 4'));
        expect(label, contains('dipilih'));
      });

      test('foodEntryLabel should include all details', () {
        final label = AccessibilityHelper.foodEntryLabel(
          foodName: 'Nasi Putih',
          servingSize: 100,
          mealTime: 'breakfast',
          calories: 130,
        );
        
        expect(label, contains('Nasi Putih'));
        expect(label, contains('100 gram'));
        expect(label, contains('Makan Pagi'));
        expect(label, contains('130 kalori'));
      });

      test('progressLabel should show percentage', () {
        final label = AccessibilityHelper.progressLabel(
          item: 'Kalori harian',
          current: 1500,
          total: 2000,
        );
        
        expect(label, contains('Kalori harian'));
        expect(label, contains('75 persen'));
      });

      test('stepCountLabel should include calories burned', () {
        final label = AccessibilityHelper.stepCountLabel(5000, 200);
        
        expect(label, contains('5000 langkah'));
        expect(label, contains('200 kalori'));
      });

      test('quizScoreLabel should show score and percentage', () {
        final label = AccessibilityHelper.quizScoreLabel(
          score: 8,
          total: 10,
        );
        
        expect(label, contains('8 dari 10'));
        expect(label, contains('80 persen'));
      });
    });

    group('AnalyticsService', () {
      late AnalyticsService analytics;

      setUp(() {
        analytics = AnalyticsService();
        analytics.clearData();
      });

      test('should track screen views', () {
        analytics.logScreenView('dashboard');
        
        final summary = analytics.getAnalyticsSummary();
        expect(summary['screen_views']['dashboard'], 1);
      });

      test('should track multiple screen views', () {
        analytics.logScreenView('dashboard');
        analytics.logScreenView('dashboard');
        analytics.logScreenView('diary');
        
        final summary = analytics.getAnalyticsSummary();
        expect(summary['screen_views']['dashboard'], 2);
        expect(summary['screen_views']['diary'], 1);
      });

      test('should track events', () {
        analytics.logEvent(name: 'button_tap');
        analytics.logEvent(name: 'button_tap');
        analytics.logEvent(name: 'feature_usage');
        
        final summary = analytics.getAnalyticsSummary();
        expect(summary['action_counts']['button_tap'], 2);
        expect(summary['action_counts']['feature_usage'], 1);
      });

      test('should log API call performance', () {
        analytics.logApiCall(
          endpoint: '/api/foods',
          durationMs: 250,
          success: true,
          statusCode: 200,
        );
        
        final metrics = analytics.getPerformanceMetrics(name: 'api_call');
        expect(metrics.length, 1);
        expect(metrics[0].value, 250);
        expect(metrics[0].attributes['endpoint'], '/api/foods');
        expect(metrics[0].attributes['success'], 'true');
      });

      test('should log database operations', () {
        analytics.logDatabaseOperation(
          operation: 'insert_food',
          durationMs: 50,
          success: true,
        );
        
        final metrics = analytics.getPerformanceMetrics(name: 'database_operation');
        expect(metrics.length, 1);
        expect(metrics[0].value, 50);
        expect(metrics[0].attributes['operation'], 'insert_food');
      });

      test('should log errors', () {
        analytics.logError(
          error: 'Test error',
          context: 'test_context',
          fatal: false,
        );
        
        final errors = analytics.getErrorLogs();
        expect(errors.length, 1);
        expect(errors[0].error, 'Test error');
        expect(errors[0].context, 'test_context');
        expect(errors[0].fatal, false);
      });

      test('should calculate average performance', () {
        analytics.logApiCall(
          endpoint: '/api/foods',
          durationMs: 200,
          success: true,
        );
        analytics.logApiCall(
          endpoint: '/api/foods',
          durationMs: 300,
          success: true,
        );
        
        final avgTime = analytics.getAveragePerformance('api_call');
        expect(avgTime, 250);
      });

      test('should filter performance metrics by name', () {
        analytics.logApiCall(
          endpoint: '/api/foods',
          durationMs: 200,
          success: true,
        );
        analytics.logDatabaseOperation(
          operation: 'insert',
          durationMs: 50,
          success: true,
        );
        
        final apiMetrics = analytics.getPerformanceMetrics(name: 'api_call');
        final dbMetrics = analytics.getPerformanceMetrics(name: 'database_operation');
        
        expect(apiMetrics.length, 1);
        expect(dbMetrics.length, 1);
      });

      test('should filter error logs by fatal flag', () {
        analytics.logError(error: 'Error 1', fatal: false);
        analytics.logError(error: 'Error 2', fatal: true);
        analytics.logError(error: 'Error 3', fatal: false);
        
        final fatalErrors = analytics.getErrorLogs(fatal: true);
        final nonFatalErrors = analytics.getErrorLogs(fatal: false);
        
        expect(fatalErrors.length, 1);
        expect(nonFatalErrors.length, 2);
      });

      test('should clear all data', () {
        analytics.logScreenView('dashboard');
        analytics.logEvent(name: 'test');
        analytics.logError(error: 'test');
        
        analytics.clearData();
        
        final summary = analytics.getAnalyticsSummary();
        expect(summary['screen_views'], isEmpty);
        expect(summary['action_counts'], isEmpty);
        expect(summary['performance_metrics_count'], 0);
        expect(summary['error_logs_count'], 0);
      });

      test('should respect enabled/disabled state', () {
        analytics.setEnabled(false);
        analytics.logScreenView('dashboard');
        
        final summary = analytics.getAnalyticsSummary();
        expect(summary['screen_views'], isEmpty);
        
        analytics.setEnabled(true);
        analytics.logScreenView('dashboard');
        
        final summary2 = analytics.getAnalyticsSummary();
        expect(summary2['screen_views']['dashboard'], 1);
      });
    });
  });
}
