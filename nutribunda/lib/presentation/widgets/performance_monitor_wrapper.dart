import 'package:flutter/material.dart';
import '../../core/services/analytics_service.dart';

/// Performance Monitor Wrapper Widget
/// Task 19.1 - Performance monitoring and analytics setup
/// 
/// Wraps screens to automatically track:
/// - Screen view events
/// - Time spent on screen
/// - Screen lifecycle
class PerformanceMonitorWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;

  const PerformanceMonitorWrapper({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  State<PerformanceMonitorWrapper> createState() => _PerformanceMonitorWrapperState();
}

class _PerformanceMonitorWrapperState extends State<PerformanceMonitorWrapper>
    with WidgetsBindingObserver {
  final AnalyticsService _analytics = AnalyticsService();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _analytics.logScreenView(widget.screenName);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isActive) {
      _analytics.logScreenExit(widget.screenName);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isActive) {
          _isActive = true;
          _analytics.logScreenView(widget.screenName);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_isActive) {
          _isActive = false;
          _analytics.logScreenExit(widget.screenName);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
