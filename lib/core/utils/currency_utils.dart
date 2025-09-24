import 'package:intl/intl.dart';

/// Currency formatting and symbol utilities.
class CurrencyUtils {
	static const Map<String, String> _currencySymbols = <String, String>{
		'USD': '4', // Fallback not ideal; prefer Intl for exact local symbol
		'EUR': '€',
		'GBP': '£',
		'KES': 'KSh',
		'JPY': '¥',
		'CNY': '¥',
		'INR': '₹',
		'NGN': '₦',
		'ZAR': 'R',
		'AUD': 'A\$',
		'CAD': 'C\$',
		'NZD': 'NZ\$',
	};

	/// Returns a formatted currency string using Intl with the given [currency] code.
	static String formatCurrency(double amount, String currency) {
		final formatter = NumberFormat.simpleCurrency(name: currency);
		return formatter.format(amount);
	}

	/// Returns the symbol for a given ISO currency code, or the code itself if unknown.
	static String getCurrencySymbol(String currencyCode) {
		final upper = currencyCode.toUpperCase();
		if (upper == 'USD') {
			return r'$';
		}
		return _currencySymbols[upper] ?? upper;
	}

	/// Returns a list of supported currency codes.
	static List<String> getSupportedCurrencies() => _currencySymbols.keys.toList(growable: false);
}
