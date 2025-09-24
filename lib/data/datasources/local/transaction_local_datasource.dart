import 'package:finance_tracker/core/utils/date_utils.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:sqflite/sqflite.dart';

abstract class TransactionLocalDataSource {
	Future<List<TransactionModel>> getAllTransactions();
	Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end);
	Future<List<TransactionModel>> searchTransactions(String query);
	Future<TransactionModel?> getTransactionById(String id);
	Future<void> insertTransaction(TransactionModel transaction);
	Future<void> updateTransaction(TransactionModel transaction);
	Future<void> deleteTransaction(String id);
	Future<void> clearAllTransactions();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
	TransactionLocalDataSourceImpl(this._db);
	final DatabaseHelper _db;

	void _log(String message) {
		// ignore: avoid_print
		print('[TransactionLocalDS] $message');
	}

	TransactionModel _fromRow(Map<String, Object?> row) {
		return TransactionModel(
			id: row['id'] as String,
			amount: (row['amount'] as num).toDouble(),
			currency: row['currency'] as String,
			date: CoreDateUtils.parseIsoString(row['date'] as String),
			description: row['description'] as String?,
			category: row['category'] as String?,
			type: _parseType(row['type'] as String),
		);
	}

	String _nowIso() => CoreDateUtils.toIsoString(DateTime.now());

	TransactionModel _validated(TransactionModel model) {
		if (model.id.trim().isEmpty) {
			throw const FormatException('Transaction.id is required');
		}
		if (model.amount <= 0) {
			throw const FormatException('Transaction.amount must be > 0');
		}
		if (model.currency.trim().isEmpty) {
			throw const FormatException('Transaction.currency is required');
		}
		return model;
	}

	TransactionType _parseType(String name) {
		return TransactionType.values.firstWhere(
			(e) => e.name == name,
			orElse: () => TransactionType.expense,
		);
	}

	Map<String, Object?> _toRow(TransactionModel model, {bool forUpdate = false}) {
		final base = <String, Object?>{
			'id': model.id,
			'amount': model.amount,
			'currency': model.currency,
			'date': CoreDateUtils.toIsoString(model.date),
			'description': model.description,
			'category': model.category,
			'type': model.type.name,
			'updated_at': _nowIso(),
		};
		if (!forUpdate) {
			base['created_at'] = _nowIso();
		}
		return base;
	}

	@override
	Future<List<TransactionModel>> getAllTransactions() async {
		try {
			final rows = await _db.query(DatabaseHelper.tableTransactions, orderBy: 'date DESC');
			return rows.map(_fromRow).toList(growable: false);
		} on DatabaseException catch (e) {
			_log('getAllTransactions db error: $e');
			rethrow;
		}
	}

	@override
	Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
		try {
			final rows = await _db.query(
				DatabaseHelper.tableTransactions,
				where: 'date >= ? AND date <= ?',
				whereArgs: [CoreDateUtils.toIsoString(start), CoreDateUtils.toIsoString(end)],
				orderBy: 'date DESC',
			);
			return rows.map(_fromRow).toList(growable: false);
		} on DatabaseException catch (e) {
			_log('getTransactionsByDateRange db error: $e');
			rethrow;
		}
	}

	@override
	Future<List<TransactionModel>> searchTransactions(String query) async {
		try {
			final like = '%${query.toLowerCase()}%';
			final rows = await _db.rawQuery(
				'SELECT * FROM ${DatabaseHelper.tableTransactions} WHERE lower(description) LIKE ? OR lower(category) LIKE ? ORDER BY date DESC',
				[like, like],
			);
			return rows.map(_fromRow).toList(growable: false);
		} on DatabaseException catch (e) {
			_log('searchTransactions db error: $e');
			rethrow;
		}
	}

	@override
	Future<TransactionModel?> getTransactionById(String id) async {
		try {
			final rows = await _db.query(
				DatabaseHelper.tableTransactions,
				where: 'id = ?',
				whereArgs: [id],
				limit: 1,
			);
			if (rows.isEmpty) return null;
			return _fromRow(rows.first);
		} on DatabaseException catch (e) {
			_log('getTransactionById db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> insertTransaction(TransactionModel transaction) async {
		try {
			final model = _validated(transaction);
			await _db.insert(
				DatabaseHelper.tableTransactions,
				_toRow(model),
				conflictAlgorithm: ConflictAlgorithm.replace,
			);
		} on DatabaseException catch (e) {
			_log('insertTransaction db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> updateTransaction(TransactionModel transaction) async {
		try {
			final model = _validated(transaction);
			await _db.update(
				DatabaseHelper.tableTransactions,
				_toRow(model, forUpdate: true),
				'id = ?',
				[model.id],
				conflictAlgorithm: ConflictAlgorithm.replace,
			);
		} on DatabaseException catch (e) {
			_log('updateTransaction db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> deleteTransaction(String id) async {
		try {
			await _db.delete(DatabaseHelper.tableTransactions, 'id = ?', [id]);
		} on DatabaseException catch (e) {
			_log('deleteTransaction db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> clearAllTransactions() async {
		try {
			await _db.execute('DELETE FROM ${DatabaseHelper.tableTransactions}');
		} on DatabaseException catch (e) {
			_log('clearAllTransactions db error: $e');
			rethrow;
		}
	}
} 