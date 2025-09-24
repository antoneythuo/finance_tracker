class Validators {
	static void validateAmount(double amount) {
		if (amount.isNaN || amount.isInfinite || amount <= 0) {
			throw ArgumentError('Amount must be a finite number greater than 0');
		}
	}

	static void validateCurrency(String currency) {
		if (currency.trim().isEmpty) {
			throw ArgumentError('Currency is required');
		}
		if (currency.length != 3) {
			throw ArgumentError('Currency must be a 3-letter ISO code');
		}
	}

	static void validateDate(DateTime date) {
		// Allow any valid DateTime; optionally ensure not too far in past/future
		if (date.year < 1900 || date.year > 2200) {
			throw ArgumentError('Date is out of supported range');
		}
	}

	static void validateDescription(String description) {
		if (description.length > 500) {
			throw ArgumentError('Description is too long');
		}
	}

	static void validateTransactionType(String type) {
		const allowed = ['income', 'expense', 'transfer'];
		if (!allowed.contains(type)) {
			throw ArgumentError('Invalid transaction type: $type');
		}
	}

	static bool isValidEmail(String email) {
		final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
		return regex.hasMatch(email);
	}

	static bool isValidPhone(String phone) {
		final regex = RegExp(r'^\+?[0-9]{7,15}$');
		return regex.hasMatch(phone);
	}
}
