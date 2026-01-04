import 'package:sqflite/sqflite.dart';
import './migrations/index.dart' as local_migrations;

abstract class Migration {
	int get version;
	String get description;
	Future<void> migrate(Database db);
}
class DatabaseMigrations {
	static final List<Migration> migrations = [
		local_migrations.BlogPostsMigration(),
		local_migrations.ImagesMigration()
	];

	static int get latestVersion => migrations.length;

	static Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
		for (var i = oldVersion; i < newVersion; i++) {
			final migration = migrations[i];
			await migration.migrate(db);
		}
	}

	static Future<void> createInitialSchema(Database db) async {
		for (var migration in migrations) {
			await migration.migrate(db);
		}
	}
}