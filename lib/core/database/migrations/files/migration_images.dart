import 'package:sqflite/sqflite.dart';
import '../../migrations.dart';

class ImagesMigration implements Migration {
	const ImagesMigration();

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