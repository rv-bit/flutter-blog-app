import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/core/database/database.dart';
import 'package:flutter_blog_app/core/exceptions/database_exceptions.dart';

final blogDAOProvider = Provider<BlogDAO>((ref) {
	return BlogDAO();
});

class BlogDAO {
	final databaseHelper = DatabaseHelper();

	Future<void> insertBlogPost(Map<String, dynamic> blog) async {
		try {
			final database = await databaseHelper.database;
			await database.insert(
				'blog_posts',
				blog,
				conflictAlgorithm: ConflictAlgorithm.replace,
			);
		} catch (e) {
			throw MyDatabaseException('Insert failed: $e');
		}
	}

	// Return a List of multiple objects aka posts, and each post will include all data like title, content, image etc.
	// TODO: #1 Will be ordered by the created time, not the updated will be later added a new function to order by selected sort type
	Future<List<Map<String, dynamic>>> getBlogPosts() async {
		final database = await databaseHelper.database;
		return await database.query(
			'blog_posts',
			where: 'is_deleted = 0',
			orderBy: 'created_at DESC',
		);
	}

	Future<Map<String, dynamic>?> getBlog(String id) async {
		final database = await databaseHelper.database;
		final res = await database.query(
			'blog_posts',
			where: 'id = ? AND is_deleted = 0',
			whereArgs: [id],
			orderBy: 'created_at DESC',
		);
		return res.isNotEmpty ? res.first : null;
	}

	Future<int> updateBlog(String id, Map<String, dynamic> data) async {
		final database = await databaseHelper.database;
		return database.update(
			'blog_posts', 
			data,
			where: 'id = ?',
			whereArgs: [id]
		);
	}

	Future<int> deleteBlog(String id) async {
		final database = await databaseHelper.database;
		return database.update(
			'blog_posts', 
			{'is_deleted': 1},
			where: 'id = ?',
			whereArgs: [id]
		);
	}

	Future<int> deleteMultiple(List<String> ids) async {
		final database = await databaseHelper.database;
		final placeholders = List.filled(ids.length, '?').join(',');

		return database.update(
			'blog_posts', 
			{'is_deleted': 1},
			where: 'id IN ($placeholders)',
			whereArgs: [ids]
		);
	}

	Future<List<Map<String, dynamic>>> searchBlogs(String query) async {
		final database = await databaseHelper.database;
		return await database.query(
			'blog_posts',
			where: '(title LIKE ? OR content LIKE ?) and is_deleted = 0',
			whereArgs: ['%$query%', '%$query%']
		);
	}
}
