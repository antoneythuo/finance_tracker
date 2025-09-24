import 'package:finance_tracker/core/utils/date_utils.dart';

/// Represents a currency exchange rate from a base currency to a target currency.
class ExchangeRateModel {
	ExchangeRateModel({
		required this.baseCurrency,
		required this.targetCurrency,
		required this.rate,
		required this.lastUpdated,
	}) : assert(baseCurrency != ''),
			 assert(targetCurrency != ''),
			 assert(rate > 0);

	factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
		final base = json['baseCurrency'] as String?;
		final target = json['targetCurrency'] as String?;
		final rawRate = json['rate'];
		final rawUpdated = json['lastUpdated'];

		if (base == null || base.trim().isEmpty) {
			throw const FormatException('baseCurrency is required');
		}
		if (target == null || target.trim().isEmpty) {
			throw const FormatException('targetCurrency is required');
		}
		double parsedRate;
		if (rawRate is num) {
			parsedRate = rawRate.toDouble();
		} else if (rawRate is String) {
			parsedRate = double.parse(rawRate);
		} else {
			throw const FormatException('rate is required');
		}
		DateTime parsedUpdated;
		if (rawUpdated is String) {
			parsedUpdated = CoreDateUtils.parseIsoString(rawUpdated);
		} else if (rawUpdated is int) {
			parsedUpdated = DateTime.fromMillisecondsSinceEpoch(rawUpdated);
		} else {
			throw const FormatException('lastUpdated is required');
		}

		return ExchangeRateModel(
			baseCurrency: base,
			targetCurrency: target,
			rate: parsedRate,
			lastUpdated: parsedUpdated,
		);
	}

	final String baseCurrency;
	final String targetCurrency;
	final double rate;
	final DateTime lastUpdated;

	Map<String, dynamic> toJson() => <String, dynamic>{
		'baseCurrency': baseCurrency,
		'targetCurrency': targetCurrency,
		'rate': rate,
		'lastUpdated': CoreDateUtils.toIsoString(lastUpdated),
	};

	/// Converts [amount] from [baseCurrency] to [targetCurrency] using [rate].
	double convertAmount(double amount) => amount * rate;

	/// Returns true if the rate is older than [maxAge].
	bool isExpired(Duration maxAge) => DateTime.now().difference(lastUpdated) > maxAge;

	@override
	String toString() => 'ExchangeRateModel(base: $baseCurrency, target: $targetCurrency, rate: $rate, lastUpdated: ${CoreDateUtils.toIsoString(lastUpdated)})';

	@override
	bool operator ==(Object other) {
		if (identical(this, other)) return true;
		return other is ExchangeRateModel &&
			other.baseCurrency == baseCurrency &&
			other.targetCurrency == targetCurrency &&
			other.rate == rate &&
			other.lastUpdated == lastUpdated;
	}

	@override
	int get hashCode => Object.hash(baseCurrency, targetCurrency, rate, lastUpdated);
} 