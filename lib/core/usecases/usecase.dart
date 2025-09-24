/// Base interface for all use cases.
///
/// Use cases encapsulate a single piece of business logic and expose a single
/// method to execute that logic. Prefer immutability and validation at the
/// boundaries.
abstract class UseCase<Result, Params> {
	Future<Result> call(Params params);
}

/// Marker type for use cases without parameters.
class NoParams {
	const NoParams();
} 