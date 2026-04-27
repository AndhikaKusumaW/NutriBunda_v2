import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base class untuk state management dengan loading, success, dan error states
abstract class ResourceState<T> extends Equatable {
  const ResourceState();

  @override
  List<Object?> get props => [];
}

/// State ketika data sedang dimuat
class Loading<T> extends ResourceState<T> {
  const Loading();
}

/// State ketika data berhasil dimuat
class Success<T> extends ResourceState<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// State ketika terjadi error
class Error<T> extends ResourceState<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// State awal sebelum ada operasi
class Initial<T> extends ResourceState<T> {
  const Initial();
}
