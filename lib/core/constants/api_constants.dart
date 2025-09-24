/// Centralized API constants for remote data sources.
class ApiConstants {
	static const String baseUrl = 'https://njuguna.free.beeceptor.com';
	static const String transactionsEndpoint = '/transactions';
	static const String exchangeRatesEndpoint = '/exchangeRtes';
	static const Duration defaultTimeout = Duration(seconds: 30);
	static const int maxRetries = 3;
}
