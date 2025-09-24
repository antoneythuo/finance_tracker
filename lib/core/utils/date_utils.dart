import 'package:intl/intl.dart';

/// Date helper utilities for consistent parsing and formatting.
class CoreDateUtils {
	static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
	static final DateFormat _dateTimeFormatter = DateFormat('MMM dd, yyyy HH:mm');

	/// Parses an ISO-8601 date string into a [DateTime].
	/// Throws [FormatException] if parsing fails.
	static DateTime parseIsoString(String dateString) {
		return DateTime.parse(dateString);
	}

	/// Formats a [DateTime] into an ISO-8601 string.
	static String toIsoString(DateTime date) => date.toIso8601String();

	/// Returns true if [date] is today in local time.
	static bool isToday(DateTime date) {
		final now = DateTime.now();
		return now.year == date.year && now.month == date.month && now.day == date.day;
	}

	/// Returns true if [date] falls within the current week (Mon-Sun) in local time.
	static bool isThisWeek(DateTime date) {
		final now = DateTime.now();
		final startOfWeek = DateTime(now.year, now.month, now.day)
			.subtract(Duration(days: (now.weekday - DateTime.monday)));
		final endOfWeek = startOfWeek.add(const Duration(days: 7));
		return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
	}

	/// Formats the [date] as "MMM dd, yyyy".
	static String formatDate(DateTime date) => _dateFormatter.format(date);

	/// Formats the [date] as "MMM dd, yyyy HH:mm" (24-hour time).
	static String formatDateTime(DateTime date) => _dateTimeFormatter.format(date);
}
