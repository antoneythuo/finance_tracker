import 'package:finance_tracker/core/utils/date_utils.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/data/models/exchange_rate_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class ExchangeRateLocalDataSource {
	Future<List<ExchangeRateModel>> getAllRates();
	Future<ExchangeRateModel?> getRate(String base, String target);
	Future<void> upsertRate(ExchangeRateModel rate);
	Future<void> upsertRates(List<ExchangeRateModel> rates);
	Future<void> deleteRate(String base, String target);
	Future<void> clearRates();
	Future<bool> isStale(ExchangeRateModel rate, {Duration maxAge});
}

class ExchangeRateLocalDataSourceImpl implements ExchangeRateLocalDataSource {
	ExchangeRateLocalDataSourceImpl(this._db);
	final DatabaseHelper _db;

	void _log(String message) {
		// ignore: avoid_print
		print('[ExchangeRateLocalDS] $message');
	}

	@override
	Future<bool> isStale(ExchangeRateModel rate, {Duration maxAge = const Duration(hours: 1)}) async {
		return DateTime.now().difference(rate.lastUpdated) > maxAge;
	}

	ExchangeRateModel _fromRow(Map<String, Object?> row) {
		return ExchangeRateModel(
			baseCurrency: row['base_currency'] as String,
			targetCurrency: row['target_currency'] as String,
			rate: (row['rate'] as num).toDouble(),
			lastUpdated: CoreDateUtils.parseIsoString(row['last_updated'] as String),
		);
	}

	Map<String, Object?> _toRow(ExchangeRateModel model) => <String, Object?>{
		'base_currency': model.baseCurrency,
		'target_currency': model.targetCurrency,
		'rate': model.rate,
		'last_updated': CoreDateUtils.toIsoString(model.lastUpdated),
	};

	@override
	Future<List<ExchangeRateModel>> getAllRates() async {
		try {
			final rows = await _db.query(DatabaseHelper.tableExchangeRates, orderBy: 'last_updated DESC');
			return rows.map(_fromRow).toList(growable: false);
		} on DatabaseException catch (e) {
			_log('getAllRates db error: $e');
			rethrow;
		}
	}

	@override
	Future<ExchangeRateModel?> getRate(String base, String target) async {
		try {
			final rows = await _db.query(
				DatabaseHelper.tableExchangeRates,
				where: 'base_currency = ? AND target_currency = ?',
				whereArgs: [base, target],
				limit: 1,
			);
			if (rows.isEmpty) return null;
			return _fromRow(rows.first);
		} on DatabaseException catch (e) {
			_log('getRate db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> upsertRate(ExchangeRateModel rate) async {
		try {
			await _db.insert(
				DatabaseHelper.tableExchangeRates,
				_toRow(rate),
				conflictAlgorithm: ConflictAlgorithm.replace,
			);
		} on DatabaseException catch (e) {
			_log('upsertRate db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> upsertRates(List<ExchangeRateModel> rates) async {
		for (final r in rates) {
			await upsertRate(r);
		}
	}

	@override
	Future<void> deleteRate(String base, String target) async {
		try {
			await _db.delete(
				DatabaseHelper.tableExchangeRates,
				'base_currency = ? AND target_currency = ?',
				[base, target],
			);
		} on DatabaseException catch (e) {
			_log('deleteRate db error: $e');
			rethrow;
		}
	}

	@override
	Future<void> clearRates() async {
		try {
			await _db.execute('DELETE FROM ${DatabaseHelper.tableExchangeRates}');
		} on DatabaseException catch (e) {
			_log('clearRates db error: $e');
			rethrow;
		}
	}
} 