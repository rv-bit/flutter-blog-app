import 'package:sqflite/sqflite.dart';

abstract class Migration {
	int get version;
	String get description;
	Future<void> migrate(Database db);
}
class DatabaseMigrations {
	static const List<Migration> migrations = [
		_Migration1(),
		_Migration2()
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

class _Migration1 implements Migration {
	const _Migration1();

	@override
	int get version => 1;

	@override
	String get description => 'Create initial blog_posts table';

	@override
	Future<void> migrate(Database db) async {
		// Create blog_posts table
		await db.execute('''
			CREATE TABLE IF NOT EXISTS blog_posts (
				id TEXT PRIMARY KEY,
				title TEXT NOT NULL,
				content TEXT NOT NULL,
				created_at TEXT NOT NULL,
				updated_at TEXT
			)
		''');

		// Create indexes for better query performance
		await db.execute('''
			CREATE INDEX IF NOT EXISTS idx_blog_content ON blog_posts(content)
		''');
		
		await db.execute('''
			CREATE INDEX IF NOT EXISTS idx_blog_created_at ON blog_posts(created_at)
		''');
	}
}

// Migration 2: Add images table
class _Migration2 implements Migration {
	const _Migration2();

	@override
	int get version => 2;

	@override
	String get description => 'Add images table';

	@override
	Future<void> migrate(Database db) async {
		await db.execute('''
			CREATE TABLE IF NOT EXISTS images (
				id TEXT PRIMARY KEY,
				blog_id TEXT NOT NULL,
				image BLOB NOT NULL,
				created_at TEXT NOT NULL,
				FOREIGN KEY (blog_id) REFERENCES blog_posts (id) ON DELETE CASCADE
			)
		''');

		// Create index for faster lookups by blogId
		await db.execute('''
			CREATE INDEX IF NOT EXISTS idx_images_blog_id ON images(blog_id)
		''');
	}
}