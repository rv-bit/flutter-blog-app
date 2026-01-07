import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blog_app/features/blog/controllers/individual_blog_controller.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/models/index.dart' as models;

@GenerateMocks([BlogRepository])
import 'individual_blog_controller_test.mocks.dart';

void main() {
	late ProviderContainer container;
	late MockBlogRepository mockRepo;

	setUp(() {
		mockRepo = MockBlogRepository();
		container = ProviderContainer(
			overrides: [
				blogRepositoryProvider.overrideWithValue(mockRepo),
			],
		);
	});

	tearDown(() {
		container.dispose();
	});

	group('IndividualBlog - build', () {
		test('loads blog by id successfully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Individual Blog',
				content: 'Blog Content',
				createdAt: now,
				images: [],
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state, isNotNull);
			expect(state!.id, '1');
			expect(state.title, 'Individual Blog');
			expect(state.content, 'Blog Content');
			verify(mockRepo.fetchBlogById('1')).called(1);
		});

		test('returns null when blog does not exist', () async {
			when(mockRepo.fetchBlogById('nonexistent')).thenAnswer((_) async => null);

			final provider = individualBlogProvider('nonexistent');
			final state = await container.read(provider.future);

			expect(state, isNull);
			verify(mockRepo.fetchBlogById('nonexistent')).called(1);
		});

		test('loads blog with multiple images', () async {
			final now = DateTime.now().toIso8601String();
			final images = [
				models.Images(id: 'img1', blogId: '1', image: 'base64_1', createdAt: now),
				models.Images(id: 'img2', blogId: '1', image: 'base64_2', createdAt: now),
				models.Images(id: 'img3', blogId: '1', image: 'base64_3', createdAt: now),
			];
			final blog = models.BlogPost(
				id: '1',
				title: 'Blog with Images',
				content: 'Content',
				createdAt: now,
				images: images,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state!.images?.length, 3);
			expect(state.images![0].id, 'img1');
			expect(state.images![1].id, 'img2');
			expect(state.images![2].id, 'img3');
		});

		test('loads blog without images', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'No Images',
				content: 'Content',
				createdAt: now,
				images: [],
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state!.images, isEmpty);
		});

		test('loads blog with updated timestamp', () async {
			final now = DateTime.now().toIso8601String();
			final updatedTime = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Updated Blog',
				content: 'Content',
				createdAt: now,
				updatedAt: updatedTime,
				images: [],
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state!.updatedAt, isNotNull);
			expect(state.updatedAt, updatedTime);
		});
	});

	group('IndividualBlog - deleteBlog', () {
		test('deletes blog successfully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'To Delete',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenAnswer((_) async => 1);

			final provider = individualBlogProvider('1');
			await container.read(provider.future); // Initial load

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			final state = await container.read(provider.future);
			expect(state, isNull);
			verify(mockRepo.deleteBlog('1')).called(1);
		});

		test('handles delete error gracefully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenThrow(Exception('Delete failed'));

			final provider = individualBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
			expect((state as AsyncError).error, isA<Exception>());
		});

		test('deletes blog with images', () async {
			final now = DateTime.now().toIso8601String();
			final images = [
				models.Images(id: 'img1', blogId: '1', image: 'base64', createdAt: now),
			];
			final blog = models.BlogPost(
				id: '1',
				title: 'With Images',
				content: 'Content',
				createdAt: now,
				images: images,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenAnswer((_) async => 1);

			final provider = individualBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			verify(mockRepo.deleteBlog('1')).called(1);
			
			final state = await container.read(provider.future);
			expect(state, isNull);
		});
	});

	group('IndividualBlog - refetchBlog', () {
		test('refetches blog successfully', () async {
			final now = DateTime.now().toIso8601String();
			final originalBlog = models.BlogPost(
				id: '1',
				title: 'Original',
				content: 'Original Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => originalBlog);

			final provider = individualBlogProvider('1');
			final initialState = await container.read(provider.future);
			expect(initialState!.title, 'Original');

			// Simulate blog being updated externally
			final updatedBlog = models.BlogPost(
				id: '1',
				title: 'Updated',
				content: 'Updated Content',
				createdAt: now,
				updatedAt: DateTime.now().toIso8601String(),
			);
			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => updatedBlog);

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final refreshedState = await container.read(provider.future);
			expect(refreshedState!.title, 'Updated');
			expect(refreshedState.content, 'Updated Content');
			expect(refreshedState.updatedAt, isNotNull);

			verify(mockRepo.fetchBlogById('1')).called(2); // Initial + refetch
		});

		test('handles refetch error', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			await container.read(provider.future);

			when(mockRepo.fetchBlogById('1')).thenThrow(Exception('Error'));

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
		});

		test('refetch returns null when blog is deleted', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = individualBlogProvider('1');
			await container.read(provider.future);

			// Simulate blog being deleted
			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => null);

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final state = await container.read(provider.future);
			expect(state, isNull);
		});

		test('refetch updates images', () async {
			final now = DateTime.now().toIso8601String();
			final originalBlog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
				images: [],
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => originalBlog);

			final provider = individualBlogProvider('1');
			final initialState = await container.read(provider.future);
			expect(initialState!.images, isEmpty);

			// Simulate images being added
			final updatedBlog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
				images: [
					models.Images(id: 'img1', blogId: '1', image: 'base64', createdAt: now),
				],
			);
			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => updatedBlog);

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final refreshedState = await container.read(provider.future);
			expect(refreshedState!.images?.length, 1);
		});
	});

	group('IndividualBlog - multiple instances', () {
		test('different IDs maintain separate state', () async {
			final now = DateTime.now().toIso8601String();
			final blog1 = models.BlogPost(
				id: '1',
				title: 'Blog 1',
				content: 'Content 1',
				createdAt: now,
			);
			final blog2 = models.BlogPost(
				id: '2',
				title: 'Blog 2',
				content: 'Content 2',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog1);
			when(mockRepo.fetchBlogById('2')).thenAnswer((_) async => blog2);

			final provider1 = individualBlogProvider('1');
			final provider2 = individualBlogProvider('2');

			final state1 = await container.read(provider1.future);
			final state2 = await container.read(provider2.future);

			expect(state1!.title, 'Blog 1');
			expect(state2!.title, 'Blog 2');
			verify(mockRepo.fetchBlogById('1')).called(1);
			verify(mockRepo.fetchBlogById('2')).called(1);
		});
	});
}