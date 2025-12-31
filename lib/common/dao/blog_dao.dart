import 'package:sqflite/sqflite.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/core/database/database.dart';
import 'package:flutter_blog_app/core/exceptions/database_exceptions.dart';

final blogDAOProvider = Provider<BlogDAO>((ref) {
	return BlogDAO();
});

class BlogDAO {
	final databaseHelper = DatabaseHelper();

	Future<void> insertBlog({
		required Map<String, dynamic> blog,
		required List<Map<String, dynamic>> images,
	}) async {
		try {
			if (blog.isEmpty) return;
			if (images.isEmpty) return;

			final database = await databaseHelper.database;

			await database.transaction((txn) async {
				await txn.insert(
					'blog_posts',
					blog,
					conflictAlgorithm: ConflictAlgorithm.abort,
				);

				for (final image in images) {
					await txn.insert(
						'images',
						image,
						conflictAlgorithm: ConflictAlgorithm.abort,
					);
				}
			});
		} catch(e) {
			log.severe('Insert failed: $e');
			throw MyDatabaseException('Insert failed: $e');
		}
	}

	// Return a List of multiple objects aka posts, and each post will include all data like content, image etc.
	// TODO: #1 Will be ordered by the created time, not the updated will be later added a new function to order by selected sort type
	Future<List<Map<String, dynamic>>> getBlogPosts({
		required int limit,
  		required int offset,
	}) async {
		final database = await databaseHelper.database;
		return await database.query(
			'blog_posts',
			limit: limit,
			offset: offset,
			where: 'is_deleted = 0',
			orderBy: 'created_at DESC',
		);
	}

	Future<List<Map<String, dynamic>>> getImagesByBlogIds(List<String> blogIds) async {
		if (blogIds.isEmpty) return [];
		
		final database = await databaseHelper.database;
		final placeholders = List.filled(blogIds.length, '?').join(',');
		
		return await database.query(
			'images',
			where: 'blog_id IN ($placeholders)',
			whereArgs: blogIds,
			orderBy: 'created_at DESC',
		);
	}

	Future<List<Map<String, dynamic>>> getImagesByBlogId(String blogId) async {
		final database = await databaseHelper.database;
		return await database.query(
			'images',
			where: 'blog_id = ?',
			whereArgs: [blogId],
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

	Future<void> insertImage(Map<String, dynamic> imageMap) async {
		final database = await databaseHelper.database;
		await database.insert(
			'images',
			imageMap,
			conflictAlgorithm: ConflictAlgorithm.replace
		);
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

	Future<void> deleteSavedImages({
		required String blogId,
		required List<String> savedImages,
	}) async {
		final database = await databaseHelper.database;

		if (savedImages.isEmpty) {
			await database.delete(
				'images',
				where: 'blog_id = ?',
				whereArgs: [blogId],
			);
			return;
		}

		final placeholders = List.filled(savedImages.length, '?').join(',');

		await database.delete(
			'images',
			where: 'blog_id = ? AND url NOT IN ($placeholders)',
			whereArgs: [blogId, ...savedImages],
		);
	}

	Future<int> deleteBlog(String id) async {
		final database = await databaseHelper.database;

		return await database.transaction((txn) async {
			await txn.delete(
				'images',
				where: 'blog_id = ?',
				whereArgs: [id],
			);

			return await txn.delete(
				'blog_posts', 
				where: 'id = ?',
				whereArgs: [id]
			);
		});
	}

	Future<int> deleteMultiple(Set<String> ids) async {
		if (ids.isEmpty) return 0;

		final database = await databaseHelper.database;

		final idList = ids.toList();
		final placeholders = List.filled(idList.length, '?').join(',');

		return await database.transaction((txn) async {
			await txn.delete(
				'images',
				where: 'blog_id IN ($placeholders)',
				whereArgs: idList,
			);

			return database.delete(
				'blog_posts', 
				where: 'id IN ($placeholders)',
				whereArgs: idList
			);
		});
	}

	Future<List<Map<String, dynamic>>> searchBlogs(String query) async {
		final database = await databaseHelper.database;
		return await database.query(
			'blog_posts',
			where: '(content LIKE ?) and is_deleted = 0',
			whereArgs: ['%$query%']
		);
	}
}
