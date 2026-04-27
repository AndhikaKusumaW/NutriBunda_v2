import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Helper class untuk common provider operations
class ProviderHelper {
  /// Get provider without listening to changes
  /// Berguna untuk memanggil methods tanpa rebuild widget
  static T read<T>(BuildContext context) {
    return context.read<T>();
  }

  /// Get provider dan listen to changes
  /// Widget akan rebuild ketika provider notify listeners
  static T watch<T>(BuildContext context) {
    return context.watch<T>();
  }

  /// Select specific value dari provider
  /// Widget hanya rebuild ketika selected value berubah
  static R select<T, R>(
    BuildContext context,
    R Function(T provider) selector,
  ) {
    return context.select<T, R>(selector);
  }

  /// Execute provider method dengan error handling
  static Future<T?> executeProviderMethod<T>(
    BuildContext context,
    Future<T> Function() method, {
    Function(String)? onError,
    Function(T)? onSuccess,
  }) async {
    try {
      final result = await method();
      if (onSuccess != null) {
        onSuccess(result);
      }
      return result;
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      } else {
        // Show default error snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return null;
    }
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message ?? 'Loading...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration,
      ),
    );
  }
}
