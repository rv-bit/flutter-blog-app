import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/common/dao/blog_dao.dart';
import 'package:flutter_blog_app/models/index.dart' as models;

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([BlogDAO])
import 'blog_repository_test.mocks.dart';

void main() {
	late BlogRepository repository;
	late MockBlogDAO mockDAO;

	setUp(() {
		mockDAO = MockBlogDAO();
		repository = BlogRepository(dao: mockDAO);
	});

	group('BlogRepository - fetchBlogs', () {
		test('returns empty list when no blogs exist', () async {
			when(mockDAO.getBlogPosts(limit: 10, offset: 0))
				.thenAnswer((_) async => []);

			final result = await repository.fetchBlogs(limit: 10, offset: 0);

			expect(result, isEmpty);
			verify(mockDAO.getBlogPosts(limit: 10, offset: 0)).called(1);
		});

		test('returns blogs without images', () async {
			final now = DateTime.now().toIso8601String();
			final blogMaps = [
				{
					'id': '1',
					'title': 'Test Blog',
					'content': 'Content',
					'created_at': now,
					'updated_at': now,
				},
			];

			when(mockDAO.getBlogPosts(limit: 10, offset: 0))
				.thenAnswer((_) async => blogMaps);
			when(mockDAO.getImagesByBlogIds(['1']))
				.thenAnswer((_) async => []);

			final result = await repository.fetchBlogs(limit: 10, offset: 0);

			expect(result.length, 1);
			expect(result.first.id, '1');
			expect(result.first.title, 'Test Blog');
			expect(result.first.images, isEmpty);
		});

		test('returns blogs with images correctly grouped', () async {
			final now = DateTime.now().toIso8601String();
			final blogMaps = [
				{'id': '1', 'title': 'Blog 1', 'content': 'Content 1', 'created_at': now, 'updated_at': now},
				{'id': '2', 'title': 'Blog 2', 'content': 'Content 2', 'created_at': now, 'updated_at': now},
			];

			// Images.fromMap expects Uint8List, not base64 string
			final imageMaps = [
				{'id': 'img1', 'blog_id': '1', 'image': Uint8List.fromList([1, 2, 3]), 'created_at': now},
				{'id': 'img2', 'blog_id': '1', 'image': Uint8List.fromList([4, 5, 6]), 'created_at': now},
				{'id': 'img3', 'blog_id': '2', 'image': Uint8List.fromList([7, 8, 9]), 'created_at': now},
			];

			when(mockDAO.getBlogPosts(limit: 10, offset: 0))
				.thenAnswer((_) async => blogMaps);
			when(mockDAO.getImagesByBlogIds(['1', '2']))
				.thenAnswer((_) async => imageMaps);

			final result = await repository.fetchBlogs(limit: 10, offset: 0);

			expect(result.length, 2);
			expect(result[0].images?.length, 2);
			expect(result[1].images?.length, 1);
			expect(result[0].images![0].blogId, '1');
			expect(result[0].images![1].blogId, '1');
			expect(result[1].images![0].blogId, '2');
		});

		test('handles pagination correctly', () async {
			final now = DateTime.now().toIso8601String();
			final blogMaps = [
				{'id': '11', 'title': 'Blog 11', 'content': 'Content', 'created_at': now, 'updated_at': now},
			];

			when(mockDAO.getBlogPosts(limit: 10, offset: 10))
				.thenAnswer((_) async => blogMaps);
			when(mockDAO.getImagesByBlogIds(['11']))
				.thenAnswer((_) async => []);

			final result = await repository.fetchBlogs(limit: 10, offset: 10);

			expect(result.length, 1);
			expect(result.first.id, '11');
		});

		test('throws exception on DAO error', () async {
			when(mockDAO.getBlogPosts(limit: 10, offset: 0))
				.thenThrow(Exception('Database error'));

			expect(
				() => repository.fetchBlogs(limit: 10, offset: 0),
				throwsException,
			);
		});
	});

	group('BlogRepository - fetchBlogById', () {
		test('returns null when blog does not exist', () async {
			when(mockDAO.getBlog('nonexistent'))
				.thenAnswer((_) async => null);

			final result = await repository.fetchBlogById('nonexistent');

			expect(result, isNull);
			verify(mockDAO.getBlog('nonexistent')).called(1);
			verifyNever(mockDAO.getImagesByBlogId(any));
		});

		test('returns blog with images', () async {
			final now = DateTime.now().toIso8601String();
			final blogMap = {
				'id': '1',
				'title': 'Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};
			final imageMaps = [
				{'id': 'img1', 'blog_id': '1', 'image': Uint8List.fromList([1, 2, 3]), 'created_at': now},
			];

			when(mockDAO.getBlog('1')).thenAnswer((_) async => blogMap);
			when(mockDAO.getImagesByBlogId('1')).thenAnswer((_) async => imageMaps);

			final result = await repository.fetchBlogById('1');

			expect(result, isNotNull);
			expect(result!.id, '1');
			expect(result.images?.length, 1);
		});

		test('returns blog without images', () async {
			final now = DateTime.now().toIso8601String();
			final blogMap = {
				'id': '2',
				'title': 'Test',
				'content': 'Content',
				'created_at': now,
				'updated_at': now,
			};

			when(mockDAO.getBlog('2')).thenAnswer((_) async => blogMap);
			when(mockDAO.getImagesByBlogId('2')).thenAnswer((_) async => []);

			final result = await repository.fetchBlogById('2');

			expect(result, isNotNull);
			expect(result!.id, '2');
			expect(result.images, isEmpty);
		});
	});

	group('BlogRepository - addBlog', () {
		test('adds blog without images', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'New Blog',
				content: 'Content',
				createdAt: now,
				images: [],
			);

			when(mockDAO.insertBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			await repository.addBlog(blog: blog, images: null);

			verify(mockDAO.insertBlog(
				blog: argThat(
					predicate<Map<String, dynamic>>((map) =>
						map['id'] == '1' && map['title'] == 'New Blog'),
					named: 'blog',
				),
				images: null,
			)).called(1);
		});

		test('adds blog with images', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'New Blog',
				content: 'Content',
				createdAt: now,
				images: [],
			);
			final images = [
				models.Images(
					id: 'img1',
					blogId: '1',
					image: 'AQID', // base64 for [1,2,3]
					createdAt: now,
				),
			];

			when(mockDAO.insertBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			await repository.addBlog(blog: blog, images: images);

			verify(mockDAO.insertBlog(
				blog: argThat(
					predicate<Map<String, dynamic>>((map) => map['id'] == '1'),
					named: 'blog',
				),
				images: argThat(
					predicate<List<Map<String, dynamic>>>((list) => list.length == 1),
					named: 'images',
				),
			)).called(1);
		});
	});

	group('BlogRepository - updateBlog', () {
		test('updates blog without changing images', () async {
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated Title',
				content: 'Updated Content',
				savedImages: null,
				newImages: null,
			);

			when(mockDAO.updateBlog('1', any))
				.thenAnswer((_) async => 1);

			await repository.updateBlog(payload);

			verify(mockDAO.updateBlog(
				'1',
				argThat(predicate<Map<String, dynamic>>((map) =>
					map['title'] == 'Updated Title' && map['content'] == 'Updated Content')),
			)).called(1);
		});

		test('updates blog and deletes removed images', () async {
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated',
				content: 'Content',
				savedImages: ['img1'],
				newImages: null,
			);

			when(mockDAO.updateBlog('1', any)).thenAnswer((_) async => 1);
			when(mockDAO.deleteSavedImages(
				blogId: anyNamed('blogId'),
				savedImages: anyNamed('savedImages'),
			)).thenAnswer((_) async => Future.value());

			await repository.updateBlog(payload);

			verify(mockDAO.updateBlog('1', any)).called(1);
			verify(mockDAO.deleteSavedImages(
				blogId: '1',
				savedImages: ['img1'],
			)).called(1);
		});
	});

	group('BlogRepository - deleteBlog', () {
		test('deletes blog successfully', () async {
			when(mockDAO.deleteBlog('1')).thenAnswer((_) async => 1);

			final result = await repository.deleteBlog('1');

			expect(result, 1);
			verify(mockDAO.deleteBlog('1')).called(1);
		});

		test('returns 0 when blog does not exist', () async {
			when(mockDAO.deleteBlog('nonexistent')).thenAnswer((_) async => 0);

			final result = await repository.deleteBlog('nonexistent');

			expect(result, 0);
		});
	});

	group('BlogRepository - deleteMultipleBlogs', () {
		test('deletes multiple blogs successfully', () async {
			when(mockDAO.deleteMultiple({'1', '2', '3'}))
				.thenAnswer((_) async => 3);

			final result = await repository.deleteMultipleBlogs({'1', '2', '3'});

			expect(result, 3);
			verify(mockDAO.deleteMultiple({'1', '2', '3'})).called(1);
		});

		test('returns 0 for empty set', () async {
			when(mockDAO.deleteMultiple({})).thenAnswer((_) async => 0);

			final result = await repository.deleteMultipleBlogs({});

			expect(result, 0);
		});
	});

	group('BlogRepository - searchBlogs', () {
		test('returns empty list for empty query', () async {
			when(mockDAO.searchBlogs('', limit: 10, offset: 0))
				.thenAnswer((_) async => []);

			final result = await repository.searchBlogs('', limit: 10, offset: 0);

			expect(result, isEmpty);
		});

		test('returns matching blogs', () async {
			final now = DateTime.now().toIso8601String();
			final blogMaps = [
				{'id': '1', 'title': 'Flutter Blog', 'content': 'About Flutter', 'created_at': now, 'updated_at': now},
			];

			when(mockDAO.searchBlogs('Flutter', limit: 10, offset: 0))
				.thenAnswer((_) async => blogMaps);

			final result = await repository.searchBlogs('Flutter', limit: 10, offset: 0);

			expect(result.length, 1);
			expect(result.first.title, 'Flutter Blog');
		});

		test('handles pagination in search', () async {
			final now = DateTime.now().toIso8601String();
			final blogMaps = [
				{'id': '11', 'title': 'Result 11', 'content': 'Content', 'created_at': now, 'updated_at': now},
			];

			when(mockDAO.searchBlogs('test', limit: 10, offset: 10))
				.thenAnswer((_) async => blogMaps);

			final result = await repository.searchBlogs('test', limit: 10, offset: 10);

			expect(result.length, 1);
		});
	});
}