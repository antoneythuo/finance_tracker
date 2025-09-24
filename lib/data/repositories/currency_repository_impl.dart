import 'dart:async';

import 'package:finance_tracker/core/constants/api_constants.dart';
import 'package:finance_tracker/core/errors/exceptions.dart';
import 'package:finance_tracker/data/datasources/remote/api_client.dart';
import 'package:finance_tracker/data/models/exchange_rate_model.dart';
import 'package:finance_tracker/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
	CurrencyRepositoryImpl({
		required ApiClientProtocol apiClient,
		Duration? cacheTtl,
	}) : _api = apiClient, _cacheTtl = cacheTtl ?? const Duration(minutes: 30);

	final ApiClientProtocol _api;
	final Duration _cacheTtl;

	List<ExchangeRateModel>? _cachedRates;
	DateTime? _cachedAt;

	bool _isCacheValid() {
		if (_cachedRates == null || _cachedAt == null) return false;
		return DateTime.now().difference(_cachedAt!) < _cacheTtl;
	}

	@override
	Future<List<ExchangeRateModel>> getExchangeRates() async {
		if (_isCacheValid()) return _cachedRates!;
		try {
			final listJson = await _api.getList(ApiConstants.exchangeRatesEndpoint);
			_cachedRates = listJson.map((e) => ExchangeRateModel.fromJson(e)).toList(growable: false);
			_cachedAt = DateTime.now();
			return _cachedRates!;
		} on ParseException {
			rethrow;
		} catch (e) {
			if (_cachedRates != null) return _cachedRates!; // fallback to stale cache
			throw NetworkException('Failed to fetch exchange rates: $e');
		}
	}

	@override
	Future<ExchangeRateModel> getExchangeRate(String fromCurrency, String toCurrency) async {
		final rates = await getExchangeRates();
		final found = rates.firstWhere(
			(r) => r.baseCurrency.toUpperCase() == fromCurrency.toUpperCase() &&
				r.targetCurrency.toUpperCase() == toCurrency.toUpperCase(),
			orElse: () => throw ParseException('Rate not found'),
		);
		return found;
	}

	@override
	Future<double> convertAmount(double amount, String from, String to) async {
		final rate = await getExchangeRate(from, to);
		return rate.convertAmount(amount);
	}

	@override
	Future<void> refreshRates() async {
		_cachedRates = null;
		_cachedAt = null;
		await getExchangeRates();
	}
} 