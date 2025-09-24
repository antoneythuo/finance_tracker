import 'dart:async';

import 'package:finance_tracker/core/constants/api_constants.dart';
import 'package:finance_tracker/core/errors/exceptions.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/datasources/remote/api_client.dart';
import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

/// Abstraction for local transaction storage. Implement in the data layer.
abstract class LocalTransactionDataSource {
	Future<List<TransactionModel>> getAll();
	Future<List<TransactionModel>> getByDateRange(DateTime start, DateTime end);
	Future<List<TransactionModel>> search(String query);
	Future<TransactionModel?> getById(String id);
	Future<void> upsert(TransactionModel model);
	Future<void> upsertMany(List<TransactionModel> models);
	Future<void> delete(String id);
}

class TransactionRepositoryImpl implements TransactionRepository {
	TransactionRepositoryImpl({
		required ApiClientProtocol apiClient,
		required LocalTransactionDataSource local,
	}) : _api = apiClient, _local = local;

	final ApiClientProtocol _api;
	final LocalTransactionDataSource _local;

	@override
	Future<List<Transaction>> getAllTransactions() async {
		try {
			final localItems = await _local.getAll();
			if (localItems.isNotEmpty) return localItems;
			// Fallback to remote if local cache empty
			final listJson = await _api.getList(ApiConstants.transactionsEndpoint);
			final models = listJson.map((e) => TransactionModel.fromJson(e)).toList(growable: false);
			await _local.upsertMany(models);
			return models;
		} on ParseException {
			rethrow;
		} on TimeoutException {
			final localItems = await _local.getAll();
			if (localItems.isNotEmpty) return localItems;
			rethrow;
		} on NetworkException {
			final localItems = await _local.getAll();
			if (localItems.isNotEmpty) return localItems;
			rethrow;
		}
	}

	@override
	Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
		final localItems = await _local.getByDateRange(start, end);
		if (localItems.isNotEmpty) return localItems;
		try {
			final listJson = await _api.getList(ApiConstants.transactionsEndpoint);
			final models = listJson.map((e) => TransactionModel.fromJson(e)).toList(growable: false);
			await _local.upsertMany(models);
			return models.where((t) => !t.date.isBefore(start) && !t.date.isAfter(end)).toList(growable: false);
		} catch (_) {
			return localItems; // fallback (possibly empty)
		}
	}

	@override
	Future<List<Transaction>> searchTransactions(String query) async {
		final localItems = await _local.search(query);
		if (localItems.isNotEmpty) return localItems;
		try {
			final listJson = await _api.getList(ApiConstants.transactionsEndpoint);
			final models = listJson.map((e) => TransactionModel.fromJson(e)).toList(growable: false);
			await _local.upsertMany(models);
			final q = query.toLowerCase();
			return models.where((t) {
				return (t.description ?? '').toLowerCase().contains(q) ||
					(t.category ?? '').toLowerCase().contains(q);
			}).toList(growable: false);
		} catch (_) {
			return localItems; // fallback
		}
	}

	@override
	Future<Transaction> getTransactionById(String id) async {
		final local = await _local.getById(id);
		if (local != null) return local;
		try {
			final listJson = await _api.getList(ApiConstants.transactionsEndpoint);
			final models = listJson.map((e) => TransactionModel.fromJson(e)).toList(growable: false);
			await _local.upsertMany(models);
			final found = models.firstWhere((t) => t.id == id, orElse: () => throw ParseException('Transaction not found'));
			return found;
		} on ParseException {
			rethrow;
		} catch (e) {
			throw NetworkException('Failed to fetch transaction: $e');
		}
	}

	@override
	Future<void> saveTransaction(Transaction transaction) async {
		final model = TransactionModel(
			id: transaction.id,
			amount: transaction.amount,
			currency: transaction.currency,
			date: transaction.date,
			description: transaction.description,
			category: transaction.category,
			type: transaction.type,
		);
		await _local.upsert(model);
		// Best-effort remote sync
		try {
			await _api.post(ApiConstants.transactionsEndpoint, model.toJson());
		} catch (e) {
			// ignore network failure to keep offline-first behavior
		}
	}

	@override
	Future<void> updateTransaction(Transaction transaction) async {
		await saveTransaction(transaction);
	}

	@override
	Future<void> deleteTransaction(String id) async {
		await _local.delete(id);
		// Remote best-effort delete (if API supported). Here we fetch and ignore if not possible.
		try {
			// No specific delete endpoint in constants; skipping actual remote delete.
		} catch (_) {}
	}

	@override
	Future<void> syncWithRemote() async {
		try {
			final listJson = await _api.getList(ApiConstants.transactionsEndpoint);
			final models = listJson.map((e) => TransactionModel.fromJson(e)).toList(growable: false);
			await _local.upsertMany(models);
		} catch (e) {
			// Log and ignore, relying on local cache
		}
	}
} 