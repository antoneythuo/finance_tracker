import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper (singleton) responsible for schema, migrations, and common ops.
class DatabaseHelper {
	DatabaseHelper._internal();
	static final DatabaseHelper instance = DatabaseHelper._internal();

	static const int _dbVersion = 1;
	static const String _dbName = 'finance_tracker.db';

	// Tables
	static const String tableTransactions = 'transactions';
	static const String tableExchangeRates = 'exchange_rates';

	Database? _db;

	Future<Database> get database async {
		if (_db != null) return _db!;
		_db = await _initDb();
		return _db!;
	}

	Future<Database> _initDb() async {
		final Directory appDir = await getApplicationDocumentsDirectory();
		final String dbPath = p.join(appDir.path, _dbName);
		return await openDatabase(
			dbPath,
			version: _dbVersion,
			onCreate: _onCreate,
			onUpgrade: _onUpgrade,
		);
	}

	Future<void> _onCreate(Database db, int version) async {
		await db.execute('''
			CREATE TABLE $tableTransactions (
				id TEXT PRIMARY KEY,
				amount REAL NOT NULL,
				currency TEXT NOT NULL,
				date TEXT NOT NULL,
				description TEXT,
				category TEXT,
				type TEXT NOT NULL,
				created_at TEXT NOT NULL,
				updated_at TEXT NOT NULL
			);
		''');
		await db.execute('CREATE INDEX idx_transactions_date ON $tableTransactions(date);');
		await db.execute('CREATE INDEX idx_transactions_category ON $tableTransactions(category);');

		await db.execute('''
			CREATE TABLE $tableExchangeRates (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				base_currency TEXT NOT NULL,
				target_currency TEXT NOT NULL,
				rate REAL NOT NULL,
				last_updated TEXT NOT NULL
			);
		''');
		await db.execute('CREATE UNIQUE INDEX idx_rates_pair ON $tableExchangeRates(base_currency, target_currency);');
	}

	Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
		// Handle future migrations here with incremental version checks
		// if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
	}

	// Generic helpers ---------------------------------------------------------
	Future<int> insert(String table, Map<String, Object?> values, {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort}) async {
		final db = await database;
		return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
	}

	Future<int> update(String table, Map<String, Object?> values, String where, List<Object?> whereArgs, {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort}) async {
		final db = await database;
		return db.update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
	}

	Future<int> delete(String table, String where, List<Object?> whereArgs) async {
		final db = await database;
		return db.delete(table, where: where, whereArgs: whereArgs);
	}

	Future<List<Map<String, Object?>>> query(String table, {bool distinct = false, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
		final db = await database;
		return db.query(
			table,
			distinct: distinct,
			columns: columns,
			where: where,
			whereArgs: whereArgs,
			groupBy: groupBy,
			having: having,
			orderBy: orderBy,
			limit: limit,
			offset: offset,
		);
	}

	Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
		final db = await database;
		return db.rawQuery(sql, arguments);
	}

	Future<void> execute(String sql, [List<Object?>? arguments]) async {
		final db = await database;
		await db.execute(sql, arguments);
	}

	// Backup and restore ------------------------------------------------------
	Future<File> backupDatabase({String? targetPath}) async {
		final Directory appDir = await getApplicationDocumentsDirectory();
		final String dbPath = p.join(appDir.path, _dbName);
		final File source = File(dbPath);
		const String backupName = 'finance_tracker.db.bak';
		final String destPath = targetPath ?? p.join(appDir.path, backupName);
		final File destination = File(destPath);
		return source.copy(destination.path);
	}

	Future<void> restoreDatabase(String backupPath) async {
		final Directory appDir = await getApplicationDocumentsDirectory();
		final String dbPath = p.join(appDir.path, _dbName);
		// Close current db if open
		if (_db != null) {
			await _db!.close();
			_db = null;
		}
		final File source = File(backupPath);
		await source.copy(dbPath);
		// Re-open
		await database;
	}
} 