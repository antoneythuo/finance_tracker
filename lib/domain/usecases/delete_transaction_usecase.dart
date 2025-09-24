import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
	DeleteTransactionUseCase(this._repository);
	final TransactionRepository _repository;

	Future<void> deleteTransaction(String id) async {
		final trimmed = id.trim();
		if (trimmed.isEmpty) {
			throw ArgumentError('id is required');
		}
		await _repository.getTransactionById(trimmed);
		await _repository.deleteTransaction(trimmed);
	}
} 