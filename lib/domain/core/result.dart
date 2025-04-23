import 'failures.dart';

/// A class representing a result that can be either success or failure.
///
/// This is similar to the Either class from functional programming,
/// but specialized for success/failure scenarios.
class Result<T> {
  final T? _success;
  final Failure? _failure;

  const Result._({
    T? success,
    Failure? failure,
  }) : _success = success,
        _failure = failure;

  /// Creates a success result with the given [value].
  factory Result.success(T? value) => Result._(success: value);

  /// Creates a failure result with the given [failure].
 factory Result.failure(Failure failure) => Result._(failure: failure);

  /// Returns true if this result is a success.
  bool get isSuccess => _failure == null;

  /// Returns true if this result is a failure.
  bool get isFailure => _failure != null;

  /// Gets the success value if available, otherwise returns null.
  T? get getOrNull => _success;

  /// Gets the failure if available, otherwise returns null.
  Failure? get failureOrNull => _failure;

  /// Transforms this result based on success or failure case.
  ///
  /// If this result is a success, [onSuccess] is called with the success value.
  /// If this result is a failure, [onFailure] is called with the failure.
  R fold<R>({
    required R Function(T) onSuccess,
    required R Function(Failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(_success as T);
    } else {
      return onFailure(_failure!);
    }
  }

  /// Maps the success value to a new value.
  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess) {
      return Result.success(transform(_success as T));
    } else {
      return Result.failure(_failure!);
    }
  }

  /// Flat maps this result to another result.
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    if (isSuccess) {
      return transform(_success as T);
    } else {
      return Result.failure(_failure!);
    }
  }
}