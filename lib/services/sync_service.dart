import 'dart:async';

import 'package:finance_tracker/services/notification_service.dart';
import 'package:finance_tracker/domain/repositories/transaction_repository.dart';
import 'package:finance_tracker/domain/repositories/currency_repository.dart';

class SyncService {
	SyncService({
		required TransactionRepository transactionRepository,
		required CurrencyRepository currencyRepository,
		NotificationService? notificationService,
	}) : _transactions = transactionRepository,
				_currency = currencyRepository,
				_notifications = notificationService ?? NotificationService();

	final TransactionRepository _transactions;
	final CurrencyRepository _currency;
	final NotificationService _notifications;

	Timer? _pollTimer;
	bool _syncInProgress = false;

	void start({Duration interval = const Duration(minutes: 5)}) {
		_pollTimer?.cancel();
		_pollTimer = Timer.periodic(interval, (_) async {
			await _safeSyncAll();
		});
	}

	void stop() {
		_pollTimer?.cancel();
	}

	Future<void> _safeSyncAll() async {
		if (_syncInProgress) return;
		_syncInProgress = true;
		try {
			await syncTransactions();
			await syncExchangeRates();
			_notifications.showSyncCompleted();
		} catch (e) {
			_notifications.showNetworkError(e.toString());
		} finally {
			_syncInProgress = false;
		}
	}

	Future<void> syncTransactions() async {
		await _transactions.syncWithRemote();
	}

	Future<void> syncExchangeRates() async {
		await _currency.refreshRates();
	}
} 