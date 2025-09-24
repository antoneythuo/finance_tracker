import 'package:finance_tracker/data/models/exchange_rate_model.dart';

/// Contract for currency exchange rates and conversions.
abstract class CurrencyRepository {
	Future<List<ExchangeRateModel>> getExchangeRates();
	Future<ExchangeRateModel> getExchangeRate(String fromCurrency, String toCurrency);
	Future<double> convertAmount(double amount, String from, String to);
	Future<void> refreshRates();
} 