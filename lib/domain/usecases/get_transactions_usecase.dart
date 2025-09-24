import 'package:finance_tracker/core/usecases/usecase.dart';
import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase implements UseCase<List<Transaction>, NoParams> {
	GetTransactionsUseCase(this._repository);
	final TransactionRepository _repository;

	@override
	Future<List<Transaction>> call(NoParams params) async {
		return _repository.getAllTransactions();
	}

	Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
		if (end.isBefore(start)) {
			throw ArgumentError('end must be on/after start');
		}
		return _repository.getTransactionsByDateRange(start, end);
	}

	Future<Transaction> getById(String id) async {
		if (id.trim().isEmpty) {
			throw ArgumentError('id cannot be empty');
		}
		return _repository.getTransactionById(id);
	}
} 