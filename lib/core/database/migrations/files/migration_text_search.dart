import 'package:sqflite_common/sqflite.dart';
import '../../migrations.dart';

class FTSBlogMigration implements Migration {
	const FTSBlogMigration();

	@override
	int get version => 1;

	@override
	String get description => 'Adds blog_posts_fts table for full text functionality';

	@override
	Future<void> migrate(Database db) async {
		// using a VIRTUAL TABLE instead of normal table
		// the virtual table allows for callback functionalities such as creating triggers of such other tables
		// these are most often used for full-text-search interfaces / functionalities, as it is perfect to read / write large query strings
		// https://www.sqlite.org/vtab.html, also used for CSV readings
		await db.execute('''
			CREATE VIRTUAL TABLE IF NOT EXISTS blog_posts_fts USING fts4(
				id,
				title,
				content,
				created_at,
				tokenize=unicode61
			)
		''');

		// this is sql triggers https://www.sqlite.org/lang_createtrigger.html, used to catch any updates, insertions, deletions from blog_posts
		// it will insert new values into the fts to help in the search functionality

		await db.execute('''
			CREATE TRIGGER IF NOT EXISTS blog_posts_ai AFTER INSERT ON blog_posts BEGIN
				INSERT INTO blog_posts_fts(id, title, content, created_at)
				VALUES (new.id, new.title, new.content, new.created_at);
			END
		''');

		await db.execute('''
			CREATE TRIGGER IF NOT EXISTS blog_posts_au AFTER UPDATE ON blog_posts BEGIN
				UPDATE blog_posts_fts 
				SET title = new.title, content = new.content, created_at = new.created_at
				WHERE id = new.id;
			END
		''');

		await db.execute('''
			CREATE TRIGGER IF NOT EXISTS blog_posts_ad AFTER DELETE ON blog_posts BEGIN
				DELETE FROM blog_posts_fts WHERE id = old.id;
			END
		''');
	}
}