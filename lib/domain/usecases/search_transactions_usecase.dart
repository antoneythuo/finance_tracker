import 'dart:async';

import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';

class SearchTransactionsUseCase {
	SearchTransactionsUseCase(this._repository);
	final TransactionRepository _repository;

	Timer? _debounce;

	Future<List<Transaction>> searchTransactions(String query) async {
		final trimmed = query.trim();
		if (trimmed.length < 2) {
			_debounce?.cancel();
			return <Transaction>[];
		}

		final completer = Completer<List<Transaction>>();
		_debounce?.cancel();
		_debounce = Timer(const Duration(milliseconds: 500), () async {
			try {
				final results = await _repository.searchTransactions(trimmed);
				completer.complete(results);
			} catch (e) {
				completer.completeError(e);
			}
		});
		return completer.future;
	}

	void dispose() {
		_debounce?.cancel();
	}
} 