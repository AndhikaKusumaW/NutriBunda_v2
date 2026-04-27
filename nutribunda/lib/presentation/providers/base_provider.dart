import 'package:flutter/foundation.dart';
import '../../core/utils/resource_state.dart';
import '../../core/errors/failures.dart';

/// Base provider class yang menyediakan common functionality untuk semua providers
/// Termasuk loading state management dan error handling
abstract class BaseProvider extends ChangeNotifier {
  @protected
  bool _isLoading = false;
  
  @protected
  bool _isDisposed = false;
  
  @protected
  Failure? _failure;

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  /// Getter untuk error/failure
  Failure? get failure => _failure;

  /// Getter untuk mengecek apakah ada error
  bool get hasError => _failure != null;

  /// Getter untuk error message
  String? get errorMessage => _failure?.message;

  /// Getter untuk disposed state
  bool get isDisposed => _isDisposed;

  /// Set loading state
  @protected
  void setLoading(bool loading, {bool notify = true}) {
    _isLoading = loading;
    if (notify) {
      safeNotifyListeners();
    }
  }

  /// Set error/failure
  @protected
  void setFailure(Failure? failure, {bool notify = true}) {
    _failure = failure;
    if (notify) {
      safeNotifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _failure = null;
    safeNotifyListeners();
  }

  /// Helper method untuk execute async operations dengan automatic loading state
  @protected
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    Function(Failure)? onError,
  }) async {
    try {
      if (showLoading) {
        setLoading(true);
      }
      clearError();

      final result = await operation();

      if (showLoading) {
        setLoading(false);
      }

      return result;
    } catch (e) {
      if (showLoading) {
        setLoading(false);
      }

      final failure = _handleException(e);
      setFailure(failure);

      if (onError != null) {
        onError(failure);
      }

      return null;
    }
  }

  /// Helper method untuk execute async operations dengan ResourceState
  @protected
  Future<ResourceState<T>> executeWithState<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      final failure = _handleException(e);
      return Error(failure);
    }
  }

  /// Convert exception to Failure
  Failure _handleException(dynamic error) {
    if (error is Failure) {
      return error;
    }

    // Log error untuk debugging
    debugPrint('BaseProvider Error: $error');

    return ServerFailure(
      message: error.toString(),
    );
  }

  /// Safe notify listeners - hanya notify jika provider belum disposed
  @protected
  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Reset provider state
  @protected
  void resetState() {
    _isLoading = false;
    _failure = null;
    safeNotifyListeners();
  }
}
