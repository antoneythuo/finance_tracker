import 'package:finance_tracker/core/utils/date_utils.dart';
import 'package:finance_tracker/domain/entities/transaction_representable.dart';

/// Data transfer model for transactions with JSON (de)serialization.
class TransactionModel extends Transaction {
	TransactionModel({
		required super.id,
		required super.amount,
		required super.currency,
		required super.date,
		super.description,
		super.category,
		super.type,
	}) : super();

	/// Creates a [TransactionModel] from a JSON map.
	///
	/// Throws [FormatException] if required fields are missing or invalid.
	factory TransactionModel.fromJson(Map<String, dynamic> json) {
		final id = json['id'] as String?;
		final currency = json['currency'] as String?;
		final rawAmount = json['amount'];
		final rawDate = json['date'];
		if (id == null || id.trim().isEmpty) {
			throw const FormatException('Transaction.id is required');
		}
		if (currency == null || currency.trim().isEmpty) {
			throw const FormatException('Transaction.currency is required');
		}
		double amount;
		if (rawAmount is num) {
			amount = rawAmount.toDouble();
		} else if (rawAmount is String) {
			amount = double.parse(rawAmount);
		} else {
			throw const FormatException('Transaction.amount is required');
		}
		DateTime date;
		if (rawDate is String) {
			date = CoreDateUtils.parseIsoString(rawDate);
		} else if (rawDate is int) {
			date = DateTime.fromMillisecondsSinceEpoch(rawDate);
		} else {
			throw const FormatException('Transaction.date is required');
		}

		final typeName = (json['type'] as String?) ?? TransactionType.expense.name;
		final type = TransactionType.values.firstWhere(
			(e) => e.name == typeName,
			orElse: () => TransactionType.expense,
		);

		return TransactionModel(
			id: id,
			amount: amount,
			currency: currency,
			date: date,
			description: json['description'] as String?,
			category: json['category'] as String?,
			type: type,
		);
	}

	/// Converts this model into a JSON map.
	Map<String, dynamic> toJson() {
		return <String, dynamic>{
			'id': id,
			'amount': amount,
			'currency': currency,
			'date': CoreDateUtils.toIsoString(date),
			'description': description,
			'category': category,
			'type': type.name,
		};
	}
} 