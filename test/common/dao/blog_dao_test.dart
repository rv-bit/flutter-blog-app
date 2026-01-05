import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_blog_app/common/dao/blog_dao.dart';
import 'package:flutter_blog_app/core/database/database.dart';

void main() {
	TestWidgetsFlutterBinding.ensureInitialized();
	sqfliteFfiInit();

	databaseFactory = databaseFactoryFfi;

	late BlogDAO blogDAO;
	late DatabaseHelper dbHelper;

	setUp(() async {
		dbHelper = DatabaseHelper.forTest(inMemoryDatabasePath);
		blogDAO = BlogDAO(databaseHelper: dbHelper);
		// Ensure database is initialized
		await dbHelper.database;
	});

	tearDown(() async {
		// Close database after each test to reset state
		await dbHelper.close();
	});

	group('BlogDAO - insertBlog', () {
		test('inserts blog successfully', () async {
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
			expect(fetched['content'], 'Hello world');
		});

		test('inserts blog with images in transaction', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'blog1',
				'title': 'Blog with Images',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			final images = [
				{
					'id': 'img1',
					'blog_id': 'blog1',
					'image': Uint8List.fromList([1, 2, 3]),
					'created_at': now,
				},
				{
					'id': 'img2',
					'blog_id': 'blog1',
					'image': Uint8List.fromList([4, 5, 6]),
					'created_at': now,
				},
			];

			await blogDAO.insertBlog(blog: blog, images: images);

			final fetchedBlog = await blogDAO.getBlog('blog1');
			expect(fetchedBlog, isNotNull);

			final fetchedImages = await blogDAO.getImagesByBlogId('blog1');
			expect(fetchedImages.length, 2);
		});

		test('throws exception on duplicate id', () async {
			final blog = {
				'id': 'duplicate',
				'title': 'Test',
				'content': 'Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};

			await blogDAO.insertBlog(blog: blog, images: null);

			expect(
				() => blogDAO.insertBlog(blog: blog, images: null),
				throwsA(anything),
			);
		});

		test('handles null images list', () async {
			final blog = {
				'id': 'test2',
				'title': 'No Images',
				'content': 'Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};

			await blogDAO.insertBlog(blog: blog, images: null);

			final images = await blogDAO.getImagesByBlogId('test2');
			expect(images, isEmpty);
		});

		test('handles empty images list', () async {
			final blog = {
				'id': 'test3',
				'title': 'Empty Images',
				'content': 'Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};

			await blogDAO.insertBlog(blog: blog, images: []);

			final images = await blogDAO.getImagesByBlogId('test3');
			expect(images, isEmpty);
		});
	});

	group('BlogDAO - getBlogPosts', () {
		test('returns paginated results ordered by created_at DESC', () async {
			for (int i = 0; i < 5; i++) {
				await Future.delayed(const Duration(milliseconds: 10));
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
			// Most recent should be first
			expect(blogs[0]['id'], 'blog4');
		});

		test('handles pagination with offset', () async {
			for (int i = 0; i < 15; i++) {
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

			final firstPage = await blogDAO.getBlogPosts(limit: 10, offset: 0);
			expect(firstPage.length, 10);

			final secondPage = await blogDAO.getBlogPosts(limit: 10, offset: 10);
			expect(secondPage.length, 5);

			// Ensure no overlap
			final firstIds = firstPage.map((b) => b['id']).toSet();
			final secondIds = secondPage.map((b) => b['id']).toSet();
			expect(firstIds.intersection(secondIds), isEmpty);
		});

		test('returns empty list when no blogs exist', () async {
			final blogs = await blogDAO.getBlogPosts(limit: 10, offset: 0);
			expect(blogs, isEmpty);
		});

		test('handles offset beyond available blogs', () async {
			await blogDAO.insertBlog(
				blog: {
					'id': 'single_blog',
					'title': 'Blog 1',
					'content': 'Content',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);

			final blogs = await blogDAO.getBlogPosts(limit: 10, offset: 100);
			expect(blogs, isEmpty);
		});
	});

	group('BlogDAO - getBlog', () {
		test('returns blog by id', () async {
			final blog = {
				'id': 'specific',
				'title': 'Specific Blog',
				'content': 'Specific Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final fetched = await blogDAO.getBlog('specific');

			expect(fetched, isNotNull);
			expect(fetched!['id'], 'specific');
			expect(fetched['title'], 'Specific Blog');
		});

		test('returns null for non-existent blog', () async {
			final fetched = await blogDAO.getBlog('nonexistent');
			expect(fetched, isNull);
		});
	});

	group('BlogDAO - updateBlog', () {
		test('updates blog successfully', () async {
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
			expect(fetched['content'], 'New Content');
		});

		test('returns 0 for non-existent blog', () async {
			final count = await blogDAO.updateBlog('nonexistent', {'title': 'New'});
			expect(count, 0);
		});

		test('returns 0 for empty id', () async {
			final count = await blogDAO.updateBlog('', {'title': 'New'});
			expect(count, 0);
		});

		test('returns 0 for empty data', () async {
			final blog = {
				'id': 'test_update',
				'title': 'Test',
				'content': 'Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final count = await blogDAO.updateBlog('test_update', {});
			expect(count, 0);
		});

		test('partially updates blog', () async {
			final blog = {
				'id': 'partial',
				'title': 'Original Title',
				'content': 'Original Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			await blogDAO.updateBlog('partial', {'title': 'New Title'});

			final fetched = await blogDAO.getBlog('partial');
			expect(fetched!['title'], 'New Title');
			expect(fetched['content'], 'Original Content'); // Unchanged
		});
	});

	group('BlogDAO - deleteBlog', () {
		test('deletes blog and its images in transaction', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'delete1',
				'title': 'To Delete',
				'content': 'Bye',
				'created_at': now,
				'updated_at': now,
			};
			final images = [
				{
					'id': 'img1',
					'blog_id': 'delete1',
					'image': Uint8List.fromList([1, 2, 3]),
					'created_at': now,
				},
			];
			await blogDAO.insertBlog(blog: blog, images: images);

			final deleted = await blogDAO.deleteBlog('delete1');
			expect(deleted, 1);

			final fetchedBlog = await blogDAO.getBlog('delete1');
			expect(fetchedBlog, isNull);

			final fetchedImages = await blogDAO.getImagesByBlogId('delete1');
			expect(fetchedImages, isEmpty);
		});

		test('returns 0 for non-existent blog', () async {
			final deleted = await blogDAO.deleteBlog('nonexistent');
			expect(deleted, 0);
		});

		test('returns 0 for empty id', () async {
			final deleted = await blogDAO.deleteBlog('');
			expect(deleted, 0);
		});
	});

	group('BlogDAO - deleteMultiple', () {
		test('deletes multiple blogs and their images', () async {
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
			expect(blogs.length, 1);
			expect(blogs[0]['id'], 'multi2');
		});

		test('returns 0 for empty set', () async {
			final count = await blogDAO.deleteMultiple({});
			expect(count, 0);
		});

		test('handles partial deletion', () async {
			await blogDAO.insertBlog(
				blog: {
					'id': 'exists',
					'title': 'Exists',
					'content': 'Content',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);

			final count = await blogDAO.deleteMultiple({'exists', 'nonexistent'});
			expect(count, 1); // Only 'exists' is deleted
		});
	});

	group('BlogDAO - getImagesByBlogId', () {
		test('returns images for specific blog ordered by created_at ASC', () async {
			final now = DateTime.now();
			final blog = {
				'id': 'img_test',
				'title': 'With Images',
				'content': 'Has images',
				'created_at': now.toIso8601String(),
				'updated_at': now.toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final images = [
				{
					'id': 'img1',
					'blog_id': 'img_test',
					'image': Uint8List.fromList([1, 2, 3]),
					'created_at': now.toIso8601String(),
				},
				{
					'id': 'img2',
					'blog_id': 'img_test',
					'image': Uint8List.fromList([4, 5, 6]),
					'created_at': now.add(const Duration(seconds: 1)).toIso8601String(),
				},
			];

			for (final img in images) {
				await blogDAO.insertImage(img);
			}

			final fetchedImages = await blogDAO.getImagesByBlogId('img_test');
			expect(fetchedImages.length, 2);
			expect(fetchedImages[0]['id'], 'img1'); // Earlier first
			expect(fetchedImages[1]['id'], 'img2');
		});

		test('returns empty list for blog with no images', () async {
			final blog = {
				'id': 'no_imgs',
				'title': 'No Images',
				'content': 'Content',
				'created_at': DateTime.now().toIso8601String(),
				'updated_at': DateTime.now().toIso8601String(),
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final images = await blogDAO.getImagesByBlogId('no_imgs');
			expect(images, isEmpty);
		});

		test('returns empty list for empty id', () async {
			final images = await blogDAO.getImagesByBlogId('');
			expect(images, isEmpty);
		});
	});

	group('BlogDAO - getImagesByBlogIds', () {
		test('returns images for multiple blogs', () async {
			final now = DateTime.now().toIso8601String();
			for (int i = 1; i <= 3; i++) {
				await blogDAO.insertBlog(
					blog: {
						'id': 'blog$i',
						'title': 'Blog $i',
						'content': 'Content',
						'created_at': now,
						'updated_at': now,
					},
					images: [
						{
							'id': 'img${i}_1',
							'blog_id': 'blog$i',
							'image': Uint8List.fromList([i, i, i]),
							'created_at': now,
						},
					],
				);
			}

			final images = await blogDAO.getImagesByBlogIds(['blog1', 'blog2']);
			expect(images.length, 2);
			expect(images.any((img) => img['id'] == 'img1_1'), isTrue);
			expect(images.any((img) => img['id'] == 'img2_1'), isTrue);
			expect(images.any((img) => img['id'] == 'img3_1'), isFalse);
		});

		test('returns empty list for empty id list', () async {
			final images = await blogDAO.getImagesByBlogIds([]);
			expect(images, isEmpty);
		});

		test('returns empty list for non-existent blogs', () async {
			final images = await blogDAO.getImagesByBlogIds(['none1', 'none2']);
			expect(images, isEmpty);
		});
	});

	group('BlogDAO - insertImage', () {
		test('inserts image successfully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'img_blog',
				'title': 'Image Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final image = {
				'id': 'imgid1',
				'blog_id': 'img_blog',
				'image': Uint8List.fromList([7, 8, 9]),
				'created_at': now,
			};
			await blogDAO.insertImage(image);

			final images = await blogDAO.getImagesByBlogId('img_blog');
			expect(images.length, 1);
			expect(images.first['id'], 'imgid1');
		});

		test('replaces existing image with same id', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'replace_blog',
				'title': 'Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			await blogDAO.insertBlog(blog: blog, images: null);

			final image1 = {
				'id': 'same_id',
				'blog_id': 'replace_blog',
				'image': Uint8List.fromList([1, 2, 3]),
				'created_at': now,
			};
			await blogDAO.insertImage(image1);

			final image2 = {
				'id': 'same_id',
				'blog_id': 'replace_blog',
				'image': Uint8List.fromList([4, 5, 6]),
				'created_at': now,
			};
			await blogDAO.insertImage(image2);

			final images = await blogDAO.getImagesByBlogId('replace_blog');
			expect(images.length, 1);
			expect((images.first['image'] as Uint8List).toList(), [4, 5, 6]);
		});
	});

	group('BlogDAO - deleteSavedImages', () {
		test('deletes all images when savedImages is empty', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'delete_imgs',
				'title': 'Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			await blogDAO.insertBlog(
				blog: blog,
				images: [
					{
						'id': 'img1',
						'blog_id': 'delete_imgs',
						'image': Uint8List.fromList([1, 2, 3]),
						'created_at': now,
					},
					{
						'id': 'img2',
						'blog_id': 'delete_imgs',
						'image': Uint8List.fromList([4, 5, 6]),
						'created_at': now,
					},
				],
			);

			await blogDAO.deleteSavedImages(blogId: 'delete_imgs', savedImages: []);

			final images = await blogDAO.getImagesByBlogId('delete_imgs');
			expect(images, isEmpty);
		});

		test('keeps only saved images', () async {
			final now = DateTime.now().toIso8601String();
			final blog = {
				'id': 'keep_imgs',
				'title': 'Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			await blogDAO.insertBlog(
				blog: blog,
				images: [
					{
						'id': 'img1',
						'blog_id': 'keep_imgs',
						'image': Uint8List.fromList([1, 2, 3]),
						'created_at': now,
					},
					{
						'id': 'img2',
						'blog_id': 'keep_imgs',
						'image': Uint8List.fromList([4, 5, 6]),
						'created_at': now,
					},
					{
						'id': 'img3',
						'blog_id': 'keep_imgs',
						'image': Uint8List.fromList([7, 8, 9]),
						'created_at': now,
					},
				],
			);

			await blogDAO.deleteSavedImages(
				blogId: 'keep_imgs',
				savedImages: ['img1', 'img3'],
			);

			final images = await blogDAO.getImagesByBlogId('keep_imgs');
			expect(images.length, 2);
			expect(images.any((img) => img['id'] == 'img1'), isTrue);
			expect(images.any((img) => img['id'] == 'img3'), isTrue);
			expect(images.any((img) => img['id'] == 'img2'), isFalse);
		});
	});

	group('BlogDAO - searchBlogs', () {
		test('returns matching blogs using FTS', () async {
			await blogDAO.insertBlog(
				blog: {
					'id': 'search1',
					'title': 'Flutter Testing Guide',
					'content': 'This is about Flutter testing',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);
			await blogDAO.insertBlog(
				blog: {
					'id': 'search2',
					'title': 'Dart Programming',
					'content': 'Learn Dart language',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);

			final results = await blogDAO.searchBlogs('Flutter', limit: 10, offset: 0);
			expect(results.length, 1);
			expect(results.first['title'], contains('Flutter'));
		});

		test('returns empty list for empty query', () async {
			final results = await blogDAO.searchBlogs('', limit: 10, offset: 0);
			expect(results, isEmpty);
		});

		test('returns empty list for whitespace query', () async {
			final results = await blogDAO.searchBlogs('   ', limit: 10, offset: 0);
			expect(results, isEmpty);
		});

		test('handles multiple search terms with OR', () async {
			await blogDAO.insertBlog(
				blog: {
					'id': 'flutter_blog',
					'title': 'Flutter App',
					'content': 'Content',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);
			await blogDAO.insertBlog(
				blog: {
					'id': 'dart_blog',
					'title': 'Dart Guide',
					'content': 'Content',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);

			final results = await blogDAO.searchBlogs('Flutter Dart', limit: 10, offset: 0);
			expect(results.length, 2); // Matches both with OR
		});

		test('handles pagination in search', () async {
			for (int i = 0; i < 15; i++) {
				await blogDAO.insertBlog(
					blog: {
						'id': 'test$i',
						'title': 'Test Blog $i',
						'content': 'Flutter content',
						'created_at': DateTime.now().toIso8601String(),
						'updated_at': DateTime.now().toIso8601String(),
					},
					images: null,
				);
			}

			final firstPage = await blogDAO.searchBlogs('Flutter', limit: 10, offset: 0);
			expect(firstPage.length, 10);

			final secondPage = await blogDAO.searchBlogs('Flutter', limit: 10, offset: 10);
			expect(secondPage.length, 5);
		});

		test('returns results ordered by created_at DESC', () async {
			final now = DateTime.now();
			await blogDAO.insertBlog(
				blog: {
					'id': 'old',
					'title': 'Flutter Old',
					'content': 'Content',
					'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
					'updated_at': now.toIso8601String(),
				},
				images: null,
			);
			await Future.delayed(const Duration(milliseconds: 10));
			await blogDAO.insertBlog(
				blog: {
					'id': 'new',
					'title': 'Flutter New',
					'content': 'Content',
					'created_at': now.toIso8601String(),
					'updated_at': now.toIso8601String(),
				},
				images: null,
			);

			final results = await blogDAO.searchBlogs('Flutter', limit: 10, offset: 0);
			expect(results.first['id'], 'new'); // Most recent first
		});

		test('returns empty list when no matches found', () async {
			await blogDAO.insertBlog(
				blog: {
					'id': 'nomatch_blog',
					'title': 'Test Blog',
					'content': 'Content',
					'created_at': DateTime.now().toIso8601String(),
					'updated_at': DateTime.now().toIso8601String(),
				},
				images: null,
			);

			final results = await blogDAO.searchBlogs('NonExistent', limit: 10, offset: 0);
			expect(results, isEmpty);
		});
	});
}