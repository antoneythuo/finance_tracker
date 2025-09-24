import 'package:intl/intl.dart';

/// Represents the minimal information required for a transaction.
///
/// All implementations should be immutable.
abstract class TransactionRepresentable {
	/// Unique identifier for the transaction
	String get id;

	/// Monetary amount of the transaction. Must be greater than 0.
	double get amount;

	/// Three-letter currency code (ISO 4217), e.g. "USD", "EUR".
	String get currency;

	/// Date and time of the transaction.
	DateTime get date;

	/// Optional human-readable description.
	String? get description;

	/// Optional category like "Food", "Rent", etc.
	String? get category;
}

/// Formatting helpers for [TransactionRepresentable].
extension TransactionFormatting on TransactionRepresentable {
	/// Returns the amount formatted with a localized currency symbol.
	///
	/// Example: 1234.5 USD -> "$1,234.50" (depending on locale)
	String get formattedAmount {
		final formatter = NumberFormat.simpleCurrency(name: currency);
		return formatter.format(amount);
	}

	/// Returns the date formatted as "MMM dd, yyyy". Example: "Jan 01, 2025".
	String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

	/// Returns the date/time formatted as "MMM dd, yyyy HH:mm" (24h).
	String get formattedDateTime => DateFormat('MMM dd, yyyy HH:mm').format(date);

	/// True if the transaction date is today (local time).
	bool get isToday {
		final now = DateTime.now();
		return now.year == date.year && now.month == date.month && now.day == date.day;
	}

	/// True if the transaction falls within the current week (Mon-Sun, local time).
	bool get isThisWeek {
		final now = DateTime.now();
		// Start of this week (Monday)
		final startOfWeek = DateTime(now.year, now.month, now.day)
			.subtract(Duration(days: (now.weekday - DateTime.monday)));
		final endOfWeek = startOfWeek.add(const Duration(days: 7));
		return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
	}
}

/// The type of transaction, used to interpret how the amount affects balances.
enum TransactionType { income, expense, transfer }

/// A concrete immutable transaction model implementing [TransactionRepresentable].
class Transaction implements TransactionRepresentable {
	/// Creates a [Transaction].
	///
	/// - [id] must be non-empty
	/// - [amount] must be greater than 0
	/// - [currency] must be a non-empty ISO 4217 code
	Transaction({
		required this.id,
		required this.amount,
		required this.currency,
		required this.date,
		this.description,
		this.category,
		this.type = TransactionType.expense,
	}) : assert(id != ''),
			 assert(amount > 0),
			 assert(currency != ''),
			 assert(currency.trim().isNotEmpty),
			 assert(id.trim().isNotEmpty);

	/// Deserializes a [Transaction] from a [Map].
	///
	/// Throws [FormatException] if required fields are missing or invalid.
	factory Transaction.fromMap(Map<String, dynamic> map) {
		try {
			final rawId = map['id'] as String?;
			final rawAmount = map['amount'];
			final rawCurrency = map['currency'] as String?;
			final rawDate = map['date'];
			final rawType = map['type'] as String?;

			if (rawId == null || rawId.trim().isEmpty) {
				throw const FormatException('id is required');
			}
			double parsedAmount;
			if (rawAmount is num) {
				parsedAmount = rawAmount.toDouble();
			} else if (rawAmount is String) {
				parsedAmount = double.parse(rawAmount);
			} else {
				throw const FormatException('amount is required');
			}
			if (rawCurrency == null || rawCurrency.trim().isEmpty) {
				throw const FormatException('currency is required');
			}
			DateTime parsedDate;
			if (rawDate is String) {
				parsedDate = DateTime.parse(rawDate);
			} else if (rawDate is int) {
				parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
			} else {
				throw const FormatException('date is required');
			}
			final parsedType = TransactionType.values.firstWhere(
				(e) => e.name == (rawType ?? TransactionType.expense.name),
				orElse: () => TransactionType.expense,
			);

			return Transaction(
				id: rawId,
				amount: parsedAmount,
				currency: rawCurrency,
				date: parsedDate,
				description: map['description'] as String?,
				category: map['category'] as String?,
				type: parsedType,
			);
		} on FormatException {
			rethrow;
		} catch (e) {
			throw FormatException('Failed to parse Transaction: $e');
		}
	}

	@override
	final String id;
	@override
	final double amount;
	@override
	final String currency;
	@override
	final DateTime date;
	@override
	final String? description;
	@override
	final String? category;

	/// The semantic type of the transaction.
	final TransactionType type;

	/// Returns a copy of this transaction with the given fields replaced.
	Transaction copyWith({
		String? id,
		double? amount,
		String? currency,
		DateTime? date,
		String? description,
		String? category,
		TransactionType? type,
	}) {
		final String nextId = id ?? this.id;
		final double nextAmount = amount ?? this.amount;
		final String nextCurrency = currency ?? this.currency;
		assert(nextId.trim().isNotEmpty, 'id must be non-empty');
		assert(nextAmount > 0, 'amount must be > 0');
		assert(nextCurrency.trim().isNotEmpty, 'currency must be non-empty');
		return Transaction(
			id: nextId,
			amount: nextAmount,
			currency: nextCurrency,
			date: date ?? this.date,
			description: description ?? this.description,
			category: category ?? this.category,
			type: type ?? this.type,
		);
	}

	/// Serializes this transaction to a JSON-friendly map.
	Map<String, dynamic> toMap() {
		return <String, dynamic>{
			'id': id,
			'amount': amount,
			'currency': currency,
			'date': date.toIso8601String(),
			'description': description,
			'category': category,
			'type': type.name,
		};
	}

	@override
	String toString() {
		return 'Transaction(id: '
				'$id, amount: $amount, currency: $currency, date: ${date.toIso8601String()}, description: $description, category: $category, type: ${type.name})';
	}

	@override
	bool operator ==(Object other) {
		if (identical(this, other)) return true;
		return other is Transaction &&
			other.id == id &&
			other.amount == amount &&
			other.currency == currency &&
			other.date == date &&
			other.description == description &&
			other.category == category &&
			other.type == type;
	}

	@override
	int get hashCode => Object.hash(
		id,
		amount,
		currency,
		date,
		description,
		category,
		type,
	);
} 