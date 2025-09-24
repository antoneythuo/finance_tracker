import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
	UpdateTransactionUseCase(this._repository);
	final TransactionRepository _repository;

	Future<void> updateTransaction(Transaction transaction) async {
		if (transaction.id.trim().isEmpty) {
			throw ArgumentError('id is required');
		}
		if (transaction.amount <= 0) {
			throw ArgumentError('amount must be > 0');
		}
		if (transaction.currency.trim().isEmpty) {
			throw ArgumentError('currency is required');
		}
		// ensure exists
		await _repository.getTransactionById(transaction.id);
		await _repository.updateTransaction(transaction);
	}
} 