import 'package:flutter/foundation.dart';

/// Analytics and Performance Monitoring Service
/// Task 19.1 - Performance monitoring and analytics setup
/// 
/// Provides:
/// - Screen view tracking
/// - User action tracking
/// - Performance metrics
/// - Error tracking
/// 
/// Note: This is a basic implementation. For production, integrate with
/// Firebase Analytics, Google Analytics, or other analytics platforms.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Performance metrics storage
  final Map<String, DateTime> _screenStartTimes = {};
  final Map<String, int> _screenViewCounts = {};
  final Map<String, int> _actionCounts = {};
  final List<PerformanceMetric> _performanceMetrics = [];
  final List<ErrorLog> _errorLogs = [];

  bool _isEnabled = true;

  /// Initialize analytics service
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('AnalyticsService: Initialized');
    }
  }

  /// Enable or disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (kDebugMode) {
      debugPrint('AnalyticsService: ${enabled ? "Enabled" : "Disabled"}');
    }
  }

  /// Log screen view
  void logScreenView(String screenName) {
    if (!_isEnabled) return;

    _screenStartTimes[screenName] = DateTime.now();
    _screenViewCounts[screenName] = (_screenViewCounts[screenName] ?? 0) + 1;

    if (kDebugMode) {
      debugPrint('AnalyticsService: Screen view - $screenName');
    }
  }

  /// Log screen exit (to calculate time spent)
  void logScreenExit(String screenName) {
    if (!_isEnabled) return;

    final startTime = _screenStartTimes[screenName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logPerformanceMetric(
        name: 'screen_time',
        value: duration.inMilliseconds.toDouble(),
        attributes: {'screen': screenName},
      );
      _screenStartTimes.remove(screenName);

      if (kDebugMode) {
        debugPrint('AnalyticsService: Screen exit - $screenName (${duration.inSeconds}s)');
      }
    }
  }

  /// Log user action/event
  void logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) {
    if (!_isEnabled) return;

    _actionCounts[name] = (_actionCounts[name] ?? 0) + 1;

    if (kDebugMode) {
      debugPrint('AnalyticsService: Event - $name ${parameters ?? ""}');
    }
  }

  /// Log button tap
  void logButtonTap(String buttonName, {String? screen}) {
    logEvent(
      name: 'button_tap',
      parameters: {
        'button_name': buttonName,
        if (screen != null) 'screen': screen,
      },
    );
  }

  /// Log feature usage
  void logFeatureUsage(String featureName) {
    logEvent(
      name: 'feature_usage',
      parameters: {'feature': featureName},
    );
  }

  /// Log search query
  void logSearch(String query, {String? category}) {
    logEvent(
      name: 'search',
      parameters: {
        'query': query,
        if (category != null) 'category': category,
      },
    );
  }

  /// Log API call performance
  void logApiCall({
    required String endpoint,
    required int durationMs,
    required bool success,
    int? statusCode,
  }) {
    _logPerformanceMetric(
      name: 'api_call',
      value: durationMs.toDouble(),
      attributes: {
        'endpoint': endpoint,
        'success': success.toString(),
        if (statusCode != null) 'status_code': statusCode.toString(),
      },
    );

    if (kDebugMode) {
      debugPrint('AnalyticsService: API call - $endpoint (${durationMs}ms, success: $success)');
    }
  }

  /// Log database operation performance
  void logDatabaseOperation({
    required String operation,
    required int durationMs,
    required bool success,
  }) {
    _logPerformanceMetric(
      name: 'database_operation',
      value: durationMs.toDouble(),
      attributes: {
        'operation': operation,
        'success': success.toString(),
      },
    );

    if (kDebugMode) {
      debugPrint('AnalyticsService: DB operation - $operation (${durationMs}ms)');
    }
  }

  /// Log app startup time
  void logAppStartup(int durationMs) {
    _logPerformanceMetric(
      name: 'app_startup',
      value: durationMs.toDouble(),
      attributes: {},
    );

    if (kDebugMode) {
      debugPrint('AnalyticsService: App startup - ${durationMs}ms');
    }
  }

  /// Log error
  void logError({
    required String error,
    String? stackTrace,
    String? context,
    bool fatal = false,
  }) {
    if (!_isEnabled) return;

    _errorLogs.add(ErrorLog(
      error: error,
      stackTrace: stackTrace,
      context: context,
      fatal: fatal,
      timestamp: DateTime.now(),
    ));

    if (kDebugMode) {
      debugPrint('AnalyticsService: Error - $error ${context != null ? "($context)" : ""}');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log user property
  void setUserProperty({
    required String name,
    required String value,
  }) {
    if (!_isEnabled) return;

    if (kDebugMode) {
      debugPrint('AnalyticsService: User property - $name: $value');
    }
  }

  /// Log user ID
  void setUserId(String userId) {
    if (!_isEnabled) return;

    if (kDebugMode) {
      debugPrint('AnalyticsService: User ID set - $userId');
    }
  }

  /// Internal: Log performance metric
  void _logPerformanceMetric({
    required String name,
    required double value,
    required Map<String, String> attributes,
  }) {
    _performanceMetrics.add(PerformanceMetric(
      name: name,
      value: value,
      attributes: attributes,
      timestamp: DateTime.now(),
    ));

    // Keep only last 1000 metrics to prevent memory issues
    if (_performanceMetrics.length > 1000) {
      _performanceMetrics.removeAt(0);
    }
  }

  /// Get analytics summary (for debugging)
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'screen_views': _screenViewCounts,
      'action_counts': _actionCounts,
      'performance_metrics_count': _performanceMetrics.length,
      'error_logs_count': _errorLogs.length,
    };
  }

  /// Get performance metrics
  List<PerformanceMetric> getPerformanceMetrics({
    String? name,
    DateTime? since,
  }) {
    var metrics = _performanceMetrics;

    if (name != null) {
      metrics = metrics.where((m) => m.name == name).toList();
    }

    if (since != null) {
      metrics = metrics.where((m) => m.timestamp.isAfter(since)).toList();
    }

    return metrics;
  }

  /// Get error logs
  List<ErrorLog> getErrorLogs({
    bool? fatal,
    DateTime? since,
  }) {
    var logs = _errorLogs;

    if (fatal != null) {
      logs = logs.where((l) => l.fatal == fatal).toList();
    }

    if (since != null) {
      logs = logs.where((l) => l.timestamp.isAfter(since)).toList();
    }

    return logs;
  }

  /// Calculate average performance for a metric
  double getAveragePerformance(String metricName) {
    final metrics = _performanceMetrics.where((m) => m.name == metricName).toList();
    if (metrics.isEmpty) return 0;

    final sum = metrics.fold<double>(0, (sum, m) => sum + m.value);
    return sum / metrics.length;
  }

  /// Clear all analytics data
  void clearData() {
    _screenStartTimes.clear();
    _screenViewCounts.clear();
    _actionCounts.clear();
    _performanceMetrics.clear();
    _errorLogs.clear();

    if (kDebugMode) {
      debugPrint('AnalyticsService: Data cleared');
    }
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final double value;
  final Map<String, String> attributes;
  final DateTime timestamp;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.attributes,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $value, attributes: $attributes, timestamp: $timestamp)';
  }
}

/// Error log data class
class ErrorLog {
  final String error;
  final String? stackTrace;
  final String? context;
  final bool fatal;
  final DateTime timestamp;

  ErrorLog({
    required this.error,
    this.stackTrace,
    this.context,
    required this.fatal,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ErrorLog(error: $error, context: $context, fatal: $fatal, timestamp: $timestamp)';
  }
}
