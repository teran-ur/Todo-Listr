/// Base contract for Domain Use Cases
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Represents UseCase calls requiring no parameters
class NoParams {
  const NoParams();
}
