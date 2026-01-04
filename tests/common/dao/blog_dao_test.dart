import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_blog_app/common/dao/blog_dao.dart';
import 'package:flutter_blog_app/core/database/database.dart';

void main() {
	TestWidgetsFlutterBinding.ensureInitialized();
	sqfliteFfiInit();

	databaseFactory = databaseFactoryFfi;

	late BlogDAO blogDAO;

	setUp(() async {
		final dbHelper = DatabaseHelper.forTest(inMemoryDatabasePath);
		blogDAO = BlogDAO(databaseHelper: dbHelper);
	});

	group('BlogDAO', () {
		test('insertBlog and getBlog', () async {
			final blog = {
				'id': 'test1',
				'title': 'Test Blog',
				'content': 'Hello world',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};

			await blogDAO.insertBlog(blog: blog, images: null);

			final fetched = await blogDAO.getBlog('test1');
			expect(fetched, isNotNull);
			expect(fetched!['title'], 'Test Blog');
		});

		test('getBlogPosts returns paginated results', () async {
			for (int i = 0; i < 5; i++) {
				await blogDAO.insertBlog(
				blog: {
					'id': 'blog$i',
					'title': 'Blog $i',
					'content': 'Content $i',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
				);
			}
			final blogs = await blogDAO.getBlogPosts(limit: 3, offset: 0);
			expect(blogs.length, 3);
		});

		test('updateBlog updates a blog', () async {
			final blog = {
				'id': 'update1',
				'title': 'Old Title',
				'content': 'Old Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final updated = {
				'title': 'New Title',
				'content': 'New Content',
				'updated_at': DateTime.now().toIso8601String(),
			};
			final count = await blogDAO.updateBlog('update1', updated);
			expect(count, 1);

			final fetched = await blogDAO.getBlog('update1');
			expect(fetched!['title'], 'New Title');
		});

		test('deleteBlog deletes a blog and its images', () async {
			final blog = {
				'id': 'delete1',
				'title': 'To Delete',
				'content': 'Bye',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final deleted = await blogDAO.deleteBlog('delete1');
			expect(deleted, 1);

			final fetched = await blogDAO.getBlog('delete1');
			expect(fetched, isNull);
		});

		test('insertImage and getImagesByBlogId', () async {
			final blog = {
				'id': 'img1',
				'title': 'With Image',
				'content': 'Has image',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final image = {
				'id': 'imgid1',
				'blog_id': 'img1',
				'image': 'base64string', // <-- use your test value
				'created_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertImage(image);

			final images = await blogDAO.getImagesByBlogId('img1');
			expect(images.length, 1);
			expect(images.first['image'], 'base64string');
		});

		test('deleteMultiple deletes multiple blogs', () async {
			for (int i = 0; i < 3; i++) {
				await blogDAO.insertBlog(
				blog: {
					'id': 'multi$i',
					'title': 'Multi $i',
					'content': 'Content $i',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
				);
			}
			final count = await blogDAO.deleteMultiple({'multi0', 'multi1'});
			expect(count, 2);

			final blogs = await blogDAO.getBlogPosts(limit: 10, offset: 0);
			expect(blogs.where((b) => b['id'].toString().startsWith('multi')).length, 1);
		});

		test('searchBlogs returns matching blogs', () async {
			await blogDAO.insertBlog(
				blog: {
				'id': 'search1',
				'title': 'Flutter Testing',
				'content': 'This is about Flutter',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);
			final results = await blogDAO.searchBlogs('Flutter', limit: 10, offset: 0);
			expect(results.any((b) => b['title'].contains('Flutter')), true);
		});
	});

}