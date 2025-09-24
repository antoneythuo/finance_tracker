import 'package:finance_tracker/data/models/exchange_rate_model.dart';
import 'package:finance_tracker/domain/repositories/currency_repository.dart';

class FetchExchangeRatesUseCase {
	FetchExchangeRatesUseCase(this._repository);
	final CurrencyRepository _repository;

	Future<List<ExchangeRateModel>> fetchRates() async {
		return _repository.getExchangeRates();
	}

	Future<double> convertAmount(double amount, String fromCurrency, String toCurrency) async {
		if (amount.isNaN || amount.isInfinite || amount < 0) {
			throw ArgumentError('amount must be a finite non-negative number');
		}
		return _repository.convertAmount(amount, fromCurrency, toCurrency);
	}

	Future<List<ExchangeRateModel>> refreshInBackground() async {
		try {
			await _repository.refreshRates();
		} catch (_) {
			// swallow network errors; caller still has cached data
		}
		return _repository.getExchangeRates();
	}
} 