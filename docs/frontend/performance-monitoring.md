# NutriBunda Performance Monitoring Guide

## Overview

This document describes the performance monitoring and analytics implementation in NutriBunda.

**Task 19.1 Implementation**: Performance monitoring and analytics setup

## Analytics Service

The `AnalyticsService` provides comprehensive tracking of user interactions, performance metrics, and errors.

### Features

1. **Screen View Tracking**: Automatically track screen views and time spent
2. **Event Tracking**: Log user actions and feature usage
3. **Performance Metrics**: Monitor API calls, database operations, and app startup
4. **Error Tracking**: Log and categorize errors for debugging
5. **User Properties**: Track user attributes and preferences

## Usage

### Initialization

The analytics service is automatically initialized in the dependency injection container:

```dart
// In injection_container.dart
await sl<AnalyticsService>().initialize();
```

### Screen View Tracking

Use the `PerformanceMonitorWrapper` to automatically track screen views:

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorWrapper(
      screenName: 'my_screen',
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

The wrapper automatically:
- Logs screen view when screen is displayed
- Tracks time spent on screen
- Logs screen exit when user navigates away
- Handles app lifecycle changes (pause/resume)

### Manual Screen Tracking

For manual control:

```dart
final analytics = AnalyticsService();

// Log screen view
analytics.logScreenView('dashboard');

// Log screen exit (to calculate time spent)
analytics.logScreenExit('dashboard');
```

### Event Tracking

#### Button Taps

```dart
analytics.logButtonTap('add_food_button', screen: 'diary');
```

#### Feature Usage

```dart
analytics.logFeatureUsage('shake_to_recipe');
analytics.logFeatureUsage('biometric_login');
analytics.logFeatureUsage('diet_plan_calculator');
```

#### Search Queries

```dart
analytics.logSearch('nasi goreng', category: 'food');
```

#### Custom Events

```dart
analytics.logEvent(
  name: 'recipe_favorited',
  parameters: {
    'recipe_id': '123',
    'recipe_name': 'Bubur Ayam',
  },
);
```

### Performance Monitoring

#### API Call Performance

```dart
final stopwatch = Stopwatch()..start();

try {
  final response = await httpClient.get('/api/foods');
  stopwatch.stop();
  
  analytics.logApiCall(
    endpoint: '/api/foods',
    durationMs: stopwatch.elapsedMilliseconds,
    success: true,
    statusCode: response.statusCode,
  );
} catch (e) {
  stopwatch.stop();
  
  analytics.logApiCall(
    endpoint: '/api/foods',
    durationMs: stopwatch.elapsedMilliseconds,
    success: false,
  );
}
```

#### Database Operations

```dart
final stopwatch = Stopwatch()..start();

try {
  await database.insert('foods', data);
  stopwatch.stop();
  
  analytics.logDatabaseOperation(
    operation: 'insert_food',
    durationMs: stopwatch.elapsedMilliseconds,
    success: true,
  );
} catch (e) {
  stopwatch.stop();
  
  analytics.logDatabaseOperation(
    operation: 'insert_food',
    durationMs: stopwatch.elapsedMilliseconds,
    success: false,
  );
}
```

#### App Startup Time

```dart
// In main.dart
void main() async {
  final stopwatch = Stopwatch()..start();
  
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  stopwatch.stop();
  AnalyticsService().logAppStartup(stopwatch.elapsedMilliseconds);
  
  runApp(MyApp());
}
```

### Error Tracking

#### Log Errors

```dart
try {
  // Some operation
} catch (e, stackTrace) {
  analytics.logError(
    error: e.toString(),
    stackTrace: stackTrace.toString(),
    context: 'loading_food_diary',
    fatal: false,
  );
}
```

#### Fatal Errors

```dart
analytics.logError(
  error: 'Database connection failed',
  context: 'app_initialization',
  fatal: true,
);
```

### User Properties

#### Set User ID

```dart
analytics.setUserId('user_123');
```

#### Set User Properties

```dart
analytics.setUserProperty(
  name: 'user_type',
  value: 'premium',
);

analytics.setUserProperty(
  name: 'has_baby',
  value: 'true',
);
```

## Analytics Data

### Retrieving Analytics Summary

```dart
final summary = analytics.getAnalyticsSummary();
print(summary);
// Output:
// {
//   'screen_views': {'dashboard': 10, 'diary': 15},
//   'action_counts': {'button_tap': 50, 'feature_usage': 20},
//   'performance_metrics_count': 100,
//   'error_logs_count': 5,
// }
```

### Performance Metrics

```dart
// Get all performance metrics
final metrics = analytics.getPerformanceMetrics();

// Get specific metric type
final apiMetrics = analytics.getPerformanceMetrics(name: 'api_call');

// Get metrics since a specific time
final recentMetrics = analytics.getPerformanceMetrics(
  since: DateTime.now().subtract(Duration(hours: 1)),
);

// Calculate average performance
final avgApiTime = analytics.getAveragePerformance('api_call');
print('Average API call time: ${avgApiTime}ms');
```

### Error Logs

```dart
// Get all error logs
final errors = analytics.getErrorLogs();

// Get only fatal errors
final fatalErrors = analytics.getErrorLogs(fatal: true);

// Get recent errors
final recentErrors = analytics.getErrorLogs(
  since: DateTime.now().subtract(Duration(hours: 1)),
);
```

## Performance Metrics

### Tracked Metrics

1. **Screen Time**: Time spent on each screen
2. **API Call Duration**: Response time for each API endpoint
3. **Database Operation Duration**: Time for database queries
4. **App Startup Time**: Time from launch to ready state

### Metric Structure

```dart
class PerformanceMetric {
  final String name;           // Metric name (e.g., 'api_call')
  final double value;          // Metric value (e.g., duration in ms)
  final Map<String, String> attributes;  // Additional context
  final DateTime timestamp;    // When metric was recorded
}
```

### Example Metrics

```dart
PerformanceMetric(
  name: 'api_call',
  value: 250.0,
  attributes: {
    'endpoint': '/api/foods',
    'success': 'true',
    'status_code': '200',
  },
  timestamp: DateTime.now(),
)

PerformanceMetric(
  name: 'screen_time',
  value: 15000.0,
  attributes: {
    'screen': 'dashboard',
  },
  timestamp: DateTime.now(),
)
```

## Error Logging

### Error Structure

```dart
class ErrorLog {
  final String error;          // Error message
  final String? stackTrace;    // Stack trace (optional)
  final String? context;       // Context where error occurred
  final bool fatal;            // Whether error is fatal
  final DateTime timestamp;    // When error occurred
}
```

### Example Error Logs

```dart
ErrorLog(
  error: 'Failed to load food data',
  stackTrace: '...',
  context: 'food_diary_screen',
  fatal: false,
  timestamp: DateTime.now(),
)

ErrorLog(
  error: 'Database initialization failed',
  context: 'app_startup',
  fatal: true,
  timestamp: DateTime.now(),
)
```

## Best Practices

### DO

✅ Track screen views for all major screens
✅ Log important user actions (button taps, feature usage)
✅ Monitor API call performance
✅ Track database operation times
✅ Log errors with context
✅ Set user properties for segmentation
✅ Use performance wrappers for automatic tracking
✅ Calculate and monitor average performance metrics

### DON'T

❌ Track personally identifiable information (PII)
❌ Log sensitive data (passwords, tokens)
❌ Track every single user interaction (be selective)
❌ Store unlimited metrics (implement data retention)
❌ Block UI thread with analytics calls
❌ Ignore error logs
❌ Track in production without user consent

## Privacy Considerations

### Data Collection

The analytics service collects:
- Screen views and navigation patterns
- Feature usage statistics
- Performance metrics (API calls, database operations)
- Error logs (without sensitive data)
- User properties (non-PII)

### Data NOT Collected

- Personally identifiable information (PII)
- User credentials or tokens
- Personal health information
- Location data (unless explicitly for LBS feature)
- Contact information

### User Consent

Implement user consent for analytics:

```dart
// Enable/disable analytics based on user preference
final userConsent = await getUserAnalyticsConsent();
analytics.setEnabled(userConsent);
```

## Integration with External Services

### Firebase Analytics (Future)

To integrate with Firebase Analytics:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  
  void logScreenView(String screenName) {
    _firebaseAnalytics.logScreenView(
      screenName: screenName,
    );
  }
  
  void logEvent({required String name, Map<String, dynamic>? parameters}) {
    _firebaseAnalytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
```

### Google Analytics (Future)

To integrate with Google Analytics:

```dart
import 'package:google_analytics/google_analytics.dart';

class AnalyticsService {
  final GoogleAnalytics _ga = GoogleAnalytics('UA-XXXXX-Y');
  
  void logScreenView(String screenName) {
    _ga.sendScreenView(screenName);
  }
  
  void logEvent({required String name, Map<String, dynamic>? parameters}) {
    _ga.sendEvent(
      category: parameters?['category'] ?? 'general',
      action: name,
      label: parameters?['label'],
    );
  }
}
```

## Debugging

### Enable Debug Logging

Debug logging is automatically enabled in debug mode:

```dart
if (kDebugMode) {
  debugPrint('AnalyticsService: Screen view - dashboard');
}
```

### View Analytics Summary

```dart
// In debug screen or developer menu
final summary = AnalyticsService().getAnalyticsSummary();
print(json.encode(summary));
```

### Clear Analytics Data

```dart
// For testing or debugging
AnalyticsService().clearData();
```

## Performance Optimization

### Batch Events

For high-frequency events, consider batching:

```dart
// Instead of logging every scroll event
// Log scroll completion or significant scroll milestones
```

### Async Logging

Analytics calls are non-blocking:

```dart
// Analytics calls don't block UI
analytics.logEvent(name: 'button_tap');
// UI continues immediately
```

### Data Retention

Implement data retention to prevent memory issues:

```dart
// Automatically keeps only last 1000 metrics
if (_performanceMetrics.length > 1000) {
  _performanceMetrics.removeAt(0);
}
```

## Monitoring Dashboard (Future)

Consider building a monitoring dashboard to visualize:

- Screen view counts and trends
- Average time spent per screen
- API call performance over time
- Error rates and types
- Feature usage statistics
- User engagement metrics

## Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Google Analytics for Mobile Apps](https://developers.google.com/analytics/devguides/collection/android)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [App Performance Monitoring](https://firebase.google.com/docs/perf-mon)

## Future Enhancements

- [ ] Integrate with Firebase Analytics
- [ ] Add custom performance traces
- [ ] Implement A/B testing support
- [ ] Add user segmentation
- [ ] Create analytics dashboard
- [ ] Implement crash reporting
- [ ] Add network performance monitoring
- [ ] Support for custom dimensions
- [ ] Implement funnel analysis
- [ ] Add cohort analysis

## Contact

For questions about analytics implementation, contact the development team.
