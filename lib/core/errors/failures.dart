/// Base failure type to express non-exceptional domain errors.
abstract class Failure {
	Failure(this.message);
	final String message;
	@override
	String toString() => '${runtimeType.toString()}: $message';
}

class NetworkFailure extends Failure {
	NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
	CacheFailure(String message) : super(message);
}

class ServerFailure extends Failure {
	ServerFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
	ValidationFailure(String message) : super(message);
}
