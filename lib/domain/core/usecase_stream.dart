/// Stream-based use case interface
///
/// [Type] The return type of the use case
/// [Params] The parameters for the use case
abstract class UseCaseStream<Type, Params> {
  /// Call method, makes a use case callable
  Stream<Type> call(Params params);
}