/// Custom exception thrown for networking-related failures.
class NetworkException implements Exception {
	NetworkException(this.message);
	final String message;
	@override
	String toString() => 'NetworkException: $message';
}

/// Custom exception thrown when the server returns an error status code.
class ServerException implements Exception {
	ServerException(this.message);
	final String message;
	@override
	String toString() => 'ServerException: $message';
}

/// Custom exception thrown when a request times out.
class TimeoutException implements Exception {
	TimeoutException(this.message);
	final String message;
	@override
	String toString() => 'TimeoutException: $message';
}

/// Custom exception thrown when parsing the server response fails.
class ParseException implements Exception {
	ParseException(this.message);
	final String message;
	@override
	String toString() => 'ParseException: $message';
}
