import '../../core/utils/resource_state.dart';
import '../../core/errors/failures.dart';
import 'base_provider.dart';

/// Provider dengan state management menggunakan ResourceState
/// Cocok untuk operasi yang memerlukan tracking state (Initial, Loading, Success, Error)
abstract class StatefulProvider<T> extends BaseProvider {
  ResourceState<T> _state = const Initial();

  /// Getter untuk current state
  ResourceState<T> get state => _state;

  /// Getter untuk mengecek apakah state adalah Loading
  bool get isStateLoading => _state is Loading<T>;

  /// Getter untuk mengecek apakah state adalah Success
  bool get isStateSuccess => _state is Success<T>;

  /// Getter untuk mengecek apakah state adalah Error
  bool get isStateError => _state is Error<T>;

  /// Getter untuk mengecek apakah state adalah Initial
  bool get isStateInitial => _state is Initial<T>;

  /// Getter untuk mendapatkan data dari Success state
  T? get data {
    if (_state is Success<T>) {
      return (_state as Success<T>).data;
    }
    return null;
  }

  /// Set state dan notify listeners
  void setState(ResourceState<T> newState) {
    _state = newState;
    
    // Update failure dan loading state tanpa notify
    if (newState is Error<T>) {
      setFailure(newState.failure, notify: false);
    } else {
      setFailure(null, notify: false);
    }
    
    setLoading(newState is Loading<T>, notify: false);
    
    // Notify listeners sekali saja
    safeNotifyListeners();
  }

  /// Helper method untuk execute operation dengan automatic state management
  Future<void> executeWithStateManagement(
    Future<T> Function() operation, {
    bool resetOnStart = true,
  }) async {
    if (resetOnStart) {
      setState(const Loading());
    }

    final result = await executeWithState(operation);
    setState(result);
  }

  @override
  void resetState() {
    _state = const Initial();
    super.resetState();
  }
}
