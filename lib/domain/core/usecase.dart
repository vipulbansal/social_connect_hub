import 'result.dart';

/// Base use case interface for operations that return a [Result]
/// and require parameters of type [P]
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  Future<Result<Type>> call(Params params);
}

/// Base use case interface for operations that return a [Result]
/// but don't require parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case without parameters
  Future<Result<Type>> call();
}

/// Base use case interface for operations that return a [Stream]
/// and require parameters of type [P]
abstract class StreamUseCase<Type, Params> {
  /// Execute the use case with the given parameters
  Stream<Type> call(Params params);
}

/// Base use case interface for operations that return a [Stream]
/// but don't require parameters
abstract class NoParamsStreamUseCase<Type> {
  /// Execute the use case without parameters
  Stream<Type> call();
}

/// Empty params class for use cases that don't need parameters
class NoParams {
  /// Constructor
  const NoParams();
}