import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:finance_tracker/core/constants/api_constants.dart';
import 'package:finance_tracker/core/errors/exceptions.dart';

/// Defines the contract for network operations used by repositories.
abstract class ApiClientProtocol {
	Future<Map<String, dynamic>> get(String endpoint);
	Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body);
	Future<List<Map<String, dynamic>>> getList(String endpoint);
}

/// Concrete HTTP client wrapper with retries, timeouts and error handling.
class ApiClient implements ApiClientProtocol {
	ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

	final http.Client _http;

	Uri _buildUri(String endpoint) {
		final trimmed = endpoint.startsWith('/') ? endpoint : '/$endpoint';
		return Uri.parse(ApiConstants.baseUrl + trimmed);
	}

	@override
	Future<Map<String, dynamic>> get(String endpoint) async {
		final uri = _buildUri(endpoint);
		final response = await _sendWithRetry(() => _http.get(uri));
		return _decodeJsonObject(response);
	}

	@override
	Future<List<Map<String, dynamic>>> getList(String endpoint) async {
		final uri = _buildUri(endpoint);
		final response = await _sendWithRetry(() => _http.get(uri));
		return _decodeJsonList(response);
	}

	@override
	Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
		final uri = _buildUri(endpoint);
		final response = await _sendWithRetry(() => _http.post(
			uri,
			headers: const {
				'Content-Type': 'application/json',
				'Accept': 'application/json',
			},
			body: jsonEncode(body),
		));
		return _decodeJsonObject(response);
	}

	Future<http.Response> _sendWithRetry(Future<http.Response> Function() send) async {
		int attempt = 0;
		late http.Response response;
		while (true) {
			attempt++;
			final startedAt = DateTime.now();
			try {
				response = await send().timeout(ApiConstants.defaultTimeout);
				_printLog('[HTTP ${response.request?.method}] ${response.request?.url} ' 
					'-> ${response.statusCode} in ${DateTime.now().difference(startedAt).inMilliseconds}ms');
				_validateStatusCode(response);
				return response;
			} on http.ClientException catch (e) {
				_printLog('ClientException: $e');
				if (attempt >= ApiConstants.maxRetries) {
					throw NetworkException('Network error: ${e.message}');
				}
			} on FormatException catch (e) {
				_printLog('FormatException: $e');
				throw ParseException('Invalid response format: ${e.message}');
			} on TimeoutException catch (e) {
				_printLog('TimeoutException: $e');
				if (attempt >= ApiConstants.maxRetries) {
					throw TimeoutException('Request timed out');
				}
			} on Exception catch (e) {
				_printLog('Unexpected exception: $e');
				if (attempt >= ApiConstants.maxRetries) {
					throw NetworkException('Unexpected network error: $e');
				}
			}

			// Exponential backoff with jitter
			final delayMs = (200 * attempt) + (DateTime.now().microsecond % 100);
			await Future.delayed(Duration(milliseconds: delayMs));
		}
	}

	void _validateStatusCode(http.Response response) {
		final status = response.statusCode;
		if (status >= 200 && status < 300) return;
		final body = response.body;
		switch (status) {
			case 400:
				throw ServerException('Bad request: $body');
			case 401:
				throw ServerException('Unauthorized');
			case 403:
				throw ServerException('Forbidden');
			case 404:
				throw ServerException('Not found');
			case 408:
				throw TimeoutException('Request timeout');
			case 429:
				throw ServerException('Too many requests');
			case 500:
			case 502:
			case 503:
			case 504:
				throw ServerException('Server error ($status)');
			default:
				throw ServerException('HTTP error ($status): $body');
		}
	}

	Map<String, dynamic> _decodeJsonObject(http.Response response) {
		try {
			final dynamic decoded = jsonDecode(response.body);
			if (decoded is Map<String, dynamic>) return decoded;
			throw const FormatException('Expected JSON object');
		} on FormatException {
			rethrow;
		} catch (e) {
			throw ParseException('Failed to parse JSON object: $e');
		}
	}

	List<Map<String, dynamic>> _decodeJsonList(http.Response response) {
		try {
			final dynamic decoded = jsonDecode(response.body);
			if (decoded is List) {
				return decoded
					.whereType<Map<String, dynamic>>()
					.toList(growable: false);
			}
			throw const FormatException('Expected JSON array of objects');
		} on FormatException {
			rethrow;
		} catch (e) {
			throw ParseException('Failed to parse JSON list: $e');
		}
	}

	void _printLog(String message) {
		// Replace with proper logging as needed.
		// ignore: avoid_print
		print('[ApiClient] $message');
	}
} 