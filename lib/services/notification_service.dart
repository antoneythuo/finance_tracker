class NotificationService {
	NotificationService();

	void showTransactionSaved() {
		// ignore: avoid_print
		print('[Notification] Transaction saved successfully.');
	}

	void showSyncCompleted() {
		// ignore: avoid_print
		print('[Notification] Sync completed successfully.');
	}

	void showNetworkError([String? message]) {
		// ignore: avoid_print
		print('[Notification] Network error: ${message ?? 'Please check your connection.'}');
	}

	void scheduleBackgroundSync() {
		// Placeholder: integrate with platform-specific scheduler if needed.
		// ignore: avoid_print
		print('[Notification] Background sync scheduled.');
	}
} 