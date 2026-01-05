import 'package:sqflite/sqflite.dart';
import '../../migrations.dart';

class BlogPostsMigration implements Migration {
	const BlogPostsMigration();

	@override
	int get version => 1;

	@override
	String get description => 'Create initial blog_posts table';

	@override
	Future<void> migrate(Database db) async {
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