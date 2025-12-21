import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/core/exceptions/database_exceptions.dart';

final log = Logger('DatabaseHelper');

class DatabaseHelper {
	static final DatabaseHelper _instance = DatabaseHelper._internal();
	factory DatabaseHelper() => _instance;
	DatabaseHelper._internal();

	static Database? _database;
	static const String _databaseName = 'blog_posts.db';
	static const int _databaseVersion = 1;

	Future<Database> get database async {
		_database ??= await _initDatabase();
		return _database!;
	}

	Future<Database> _initDatabase() async {
		try {
			final documentsDirectory = await getApplicationDocumentsDirectory();
			final path = join(documentsDirectory.path, _databaseName);

			return await openDatabase(
				path,
				version: _databaseVersion,
				onCreate: _onCreate,
				onConfigure: _onConfigure,
			);
		} catch (e) {
			throw MyDatabaseException('Something went wrong, $e');
		}
	}

	// Enable foreign keys and other constraints
	Future<void> _onConfigure(Database db) async {
		await db.execute('PRAGMA foreign_keys = ON');
	}

	Future<void> _onCreate(Database db, int version) async {
		await db.execute('''
			CREATE TABLE blog_posts (
				id TEXT PRIMARY KEY,
				title TEXT NOT NULL,
				content TEXT NOT NULL,
				created_at TEXT NOT NULL,
				updated_at TEXT NOT NULL,
				deleted_at TEXT NOT NULL,
				image TEXT,
				is_deleted INTEGER NOT NULL DEFAULT 0
			)
		''');

		// Create index for better query performance
		await db.execute('''
			CREATE INDEX idx_blog_title ON blog_posts(title)
		''');
		await db.execute('''
			CREATE INDEX idx_blog_content ON blog_posts(content)
		''');
		await db.execute('''
			CREATE INDEX idx_blog_created_at ON blog_posts(created_at)
		''');
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
	}
}
