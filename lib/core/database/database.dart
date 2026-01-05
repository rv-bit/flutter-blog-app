import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/core/database/migrations.dart';

final log = Logger('DatabaseHelper');

class DatabaseHelper {
	final String? overridePath;
	static final DatabaseHelper _instance = DatabaseHelper._internal();
	factory DatabaseHelper() => _instance;
	DatabaseHelper._internal() : overridePath = null;

	DatabaseHelper.forTest(this.overridePath);

	static Database? _database;
	static const String _databaseName = 'app.db';
	static int get _databaseVersion => DatabaseMigrations.latestVersion;

	Future<Database> get database async {
		if (_database != null) return _database!;
			if (overridePath != null) {
			_database = await openDatabase(
				overridePath!,
				version: _databaseVersion,
				onCreate: _onCreate,
				onConfigure: _onConfigure,
				onUpgrade: _onUpgrade,
			);
		} else {
			final documentsDirectory = await getApplicationDocumentsDirectory();
			final path = join(documentsDirectory.path, "app.db");
			_database = await openDatabase(
				path,
				version: _databaseVersion,
				onCreate: _onCreate,
				onConfigure: _onConfigure,
				onUpgrade: _onUpgrade,
			);
		}
		return _database!;
	}

	Future<int> getDatabaseVersion() async {
		final db = await database;
		return await db.getVersion();
	}

	// Enable foreign keys and other constraints
	Future<void> _onConfigure(Database db) async {
		await db.execute('PRAGMA foreign_keys = ON');
		log.info('Foreign keys enabled');
	}

	Future<void> _onCreate(Database db, int version) async {
		log.info('Creating database with version: $version');
		
		try {
			await DatabaseMigrations.createInitialSchema(db);
			log.info('Database schema created successfully');
		} catch (e) {
			log.severe('Error creating database schema: $e');
			rethrow;
		}
	}

	Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
		log.info('Upgrading database from version $oldVersion to $newVersion');
		
		try {
			await DatabaseMigrations.runMigrations(db, oldVersion, newVersion);
			log.info('Database upgraded successfully');
		} catch (e) {
			log.severe('Error upgrading database: $e');
			rethrow;
		}
	}

	Future<void> close() async {
		final db = await database;
		await db.close();
		_database = null;
	}

	// Reset database (useful for testing)
	Future<void> deleteDatabase() async {
		final documentsDirectory = await getApplicationDocumentsDirectory();
		final path = join(documentsDirectory.path, _databaseName);
		await databaseFactory.deleteDatabase(path);
		_database = null;
		log.info('Database deleted');
	}

	Future<bool> needsMigration() async {
		final currentVersion = await getDatabaseVersion();
		return currentVersion < _databaseVersion;
	}
}
