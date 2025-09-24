import 'dart:async';

import 'package:finance_tracker/core/constants/api_constants.dart';
import 'package:finance_tracker/data/datasources/remote/api_client.dart';
import 'package:finance_tracker/data/models/exchange_rate_model.dart';

class CurrencyService {
	factory CurrencyService(ApiClientProtocol apiClient) {
		_instance ??= CurrencyService._(apiClient);
		return _instance!;
	}
	CurrencyService._(this._api);
	static CurrencyService? _instance;

	final ApiClientProtocol _api;

	// Cache
	List<ExchangeRateModel>? _cachedRates;
	DateTime? _lastFetchAt;

	// Background refresh timer
	Timer? _refreshTimer;

	// Rate limiting
	DateTime? _lastApiCallAt;
	int _callsInWindow = 0;
	DateTime _windowStart = DateTime.now();
	static const int _maxCallsPerMinute = 30;
	static const Duration _minFetchInterval = Duration(seconds: 15);

	void startBackgroundRefresh({Duration interval = const Duration(minutes: 30)}) {
		_refreshTimer?.cancel();
		_refreshTimer = Timer.periodic(interval, (_) async {
			try {
				await fetchExchangeRates(force: false);
			} catch (_) {
				// swallow errors in background
			}
		});
	}

	void dispose() {
		_refreshTimer?.cancel();
	}

	bool _withinRateLimit() {
		final now = DateTime.now();
		// Sliding window reset
		if (now.difference(_windowStart) >= const Duration(minutes: 1)) {
			_windowStart = now;
			_callsInWindow = 0;
		}
		if (_callsInWindow >= _maxCallsPerMinute) return false;
		_callsInWindow += 1;
		// Minimal interval between calls
		if (_lastApiCallAt != null && now.difference(_lastApiCallAt!) < _minFetchInterval) {
			return false;
		}
		_lastApiCallAt = now;
		return true;
	}

	Future<List<ExchangeRateModel>> fetchExchangeRates({bool force = true}) async {
		final now = DateTime.now();
		if (!force && _cachedRates != null && _lastFetchAt != null) {
			// 1-hour freshness
			if (now.difference(_lastFetchAt!) < const Duration(hours: 1)) {
				return _cachedRates!;
			}
		}
		if (!_withinRateLimit()) {
			return _cachedRates ?? <ExchangeRateModel>[];
		}
		final list = await _api.getList(ApiConstants.exchangeRatesEndpoint);
		_cachedRates = list.map((e) => ExchangeRateModel.fromJson(e)).toList(growable: false);
		_lastFetchAt = DateTime.now();
		return _cachedRates!;
	}

	List<ExchangeRateModel> getCachedRates() => _cachedRates ?? <ExchangeRateModel>[];

	Future<double> convertCurrency(double amount, String from, String to) async {
		if (from.toUpperCase() == to.toUpperCase()) return amount;
		final rates = _cachedRates ?? await fetchExchangeRates(force: false);
		final rate = rates.firstWhere(
			(r) => r.baseCurrency.toUpperCase() == from.toUpperCase() && r.targetCurrency.toUpperCase() == to.toUpperCase(),
			orElse: () => throw StateError('Missing exchange rate for $from->$to'),
		);
		return rate.convertAmount(amount);
	}
} 