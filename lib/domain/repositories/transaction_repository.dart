import 'package:finance_tracker/domain/entities/transaction_representable.dart';

/// Contract for accessing and mutating transactions regardless of data source.
abstract class TransactionRepository {
	Future<List<Transaction>> getAllTransactions();
	Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
	Future<List<Transaction>> searchTransactions(String query);
	Future<Transaction> getTransactionById(String id);
	Future<void> saveTransaction(Transaction transaction);
	Future<void> updateTransaction(Transaction transaction);
	Future<void> deleteTransaction(String id);
	Future<void> syncWithRemote();
} 