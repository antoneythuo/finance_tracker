import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

class SaveTransactionUseCase {
	SaveTransactionUseCase(this._repository);
	final TransactionRepository _repository;

	Future<void> saveTransaction(Transaction transaction) async {
		final String id = (transaction.id).trim().isEmpty
			? 'tx_${DateTime.now().microsecondsSinceEpoch}'
			: transaction.id.trim();
		if (transaction.amount <= 0) {
			throw ArgumentError('amount must be > 0');
		}
		if (transaction.currency.trim().isEmpty) {
			throw ArgumentError('currency is required');
		}

		// Timestamps are persisted at the DB layer; ensure updated timestamp semantics by passing through.
		final enriched = Transaction(
			id: id,
			amount: transaction.amount,
			currency: transaction.currency,
			date: transaction.date,
			description: transaction.description,
			category: transaction.category,
			type: transaction.type,
		);
		await _repository.saveTransaction(enriched);
	}
} 