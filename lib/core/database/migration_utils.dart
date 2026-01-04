import 'package:logging/logging.dart';

import './database.dart';
import './migrations.dart';

final log = Logger('MigrationUtils');

class MigrationUtils {
	static final DatabaseHelper _dbHelper = DatabaseHelper();

	static Future<void> printCurrentVersion() async {
		final version = await _dbHelper.getDatabaseVersion();
		log.info('Current database version: $version');
	}

	static void printAllMigrations() {
		log.info('Available migrations (Total: ${DatabaseMigrations.latestVersion}):');
		for (var migration in DatabaseMigrations.migrations) {
			log.info('v${migration.version}: ${migration.description}');
		}
	}

	static Future<bool> checkMigrationStatus() async {
		final needsMigration = await _dbHelper.needsMigration();
		final currentVersion = await _dbHelper.getDatabaseVersion();
		
		if (needsMigration) {
			log.warning('Migration needed! Current: v$currentVersion, ''Target: v${DatabaseMigrations.latestVersion}');
		} else {
			log.info('Database is up to date (v$currentVersion)');
		}
		
		return needsMigration;
	}

	static Future<void> resetDatabase() async {
		log.warning('Resetting database');
		await _dbHelper.deleteDatabase();
		await _dbHelper.database; // Recreate
		log.info('Database reset complete');
	}
}