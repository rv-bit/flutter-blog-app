import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blog_app/features/blog/controllers/blog_edit_controller.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/models/index.dart' as models;

@GenerateMocks([BlogRepository])
import 'blog_edit_controller_test.mocks.dart';

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

	group('EditBlog - build', () {
		test('loads blog by id successfully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test Blog',
				content: 'Test Content',
				createdAt: now,
				images: [],
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = editBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state, isNotNull);
			expect(state!.id, '1');
			expect(state.title, 'Test Blog');
			verify(mockRepo.fetchBlogById('1')).called(1);
		});

		test('returns null when blog does not exist', () async {
			when(mockRepo.fetchBlogById('nonexistent')).thenAnswer((_) async => null);

			final provider = editBlogProvider('nonexistent');
			final state = await container.read(provider.future);

			expect(state, isNull);
			verify(mockRepo.fetchBlogById('nonexistent')).called(1);
		});

		test('loads blog with images', () async {
			final now = DateTime.now().toIso8601String();
			final images = [
				models.Images(id: 'img1', blogId: '1', image: 'base64data', createdAt: now),
			];
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
				images: images,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);

			final provider = editBlogProvider('1');
			final state = await container.read(provider.future);

			expect(state!.images?.length, 1);
			expect(state.images!.first.id, 'img1');
		});
	});

	group('EditBlog - updateBlog', () {
		test('updates blog successfully', () async {
			final now = DateTime.now().toIso8601String();
			final originalBlog = models.BlogPost(
				id: '1',
				title: 'Original',
				content: 'Original Content',
				createdAt: now,
			);
			final updatedBlog = models.BlogPost(
				id: '1',
				title: 'Updated',
				content: 'Updated Content',
				createdAt: now,
				updatedAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => originalBlog);
			when(mockRepo.updateBlog(any)).thenAnswer((_) async => Future.value());

			final provider = editBlogProvider('1');
			await container.read(provider.future); // Initial load

			// After update, return the updated blog
			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => updatedBlog);

			final notifier = container.read(provider.notifier);
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated',
				content: 'Updated Content',
				savedImages: null,
				newImages: null,
			);

			await notifier.updateBlog(payload);

			final state = await container.read(provider.future);
			expect(state!.title, 'Updated');
			verify(mockRepo.updateBlog(any)).called(1);
		});

		test('handles update error', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.updateBlog(any)).thenThrow(Exception('Update failed'));

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated',
				content: 'Updated',
				savedImages: null,
				newImages: null,
			);

			await notifier.updateBlog(payload);

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
		});

		test('updates blog with saved images', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.updateBlog(any)).thenAnswer((_) async => Future.value());

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated',
				content: 'Updated',
				savedImages: ['img1', 'img2'],
				newImages: null,
			);

			await notifier.updateBlog(payload);

			verify(mockRepo.updateBlog(
				argThat(predicate<models.UpdateBlogPayload>(
					(p) => p.savedImages?.length == 2,
				)),
			)).called(1);
		});

		test('refetches blog after successful update', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Original',
				content: 'Content',
				createdAt: now,
			);
			final updatedBlog = models.BlogPost(
				id: '1',
				title: 'Updated',
				content: 'Updated Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.updateBlog(any)).thenAnswer((_) async => Future.value());

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => updatedBlog);

			final notifier = container.read(provider.notifier);
			final payload = models.UpdateBlogPayload(
				blogId: '1',
				title: 'Updated',
				content: 'Updated Content',
			);

			await notifier.updateBlog(payload);

			// Verify fetchBlogById was called twice: once on build, once after update
			verify(mockRepo.fetchBlogById('1')).called(2);
		});
	});

	group('EditBlog - deleteBlog', () {
		test('deletes blog successfully', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenAnswer((_) async => 1);

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			final state = await container.read(provider.future);
			expect(state, isNull);
			verify(mockRepo.deleteBlog('1')).called(1);
		});

		test('handles delete error', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenThrow(Exception('Delete failed'));

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
		});

		test('sets state to null after successful delete', () async {
			final now = DateTime.now().toIso8601String();
			final blog = models.BlogPost(
				id: '1',
				title: 'Test',
				content: 'Content',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog);
			when(mockRepo.deleteBlog('1')).thenAnswer((_) async => 1);

			final provider = editBlogProvider('1');
			final initialState = await container.read(provider.future);
			expect(initialState, isNotNull);

			final notifier = container.read(provider.notifier);
			await notifier.deleteBlog();

			final deletedState = await container.read(provider.future);
			expect(deletedState, isNull);
		});
	});

	group('EditBlog - refetchBlog', () {
		test('refetches blog successfully', () async {
			final now = DateTime.now().toIso8601String();
			final originalBlog = models.BlogPost(
				id: '1',
				title: 'Original',
				content: 'Original',
				createdAt: now,
			);
			final refreshedBlog = models.BlogPost(
				id: '1',
				title: 'Refreshed',
				content: 'Refreshed',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1'))
				.thenAnswer((_) async => originalBlog);

			final provider = editBlogProvider('1');
			final initialState = await container.read(provider.future);
			expect(initialState!.title, 'Original');

			when(mockRepo.fetchBlogById('1'))
				.thenAnswer((_) async => refreshedBlog);

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final refreshedState = await container.read(provider.future);
			expect(refreshedState!.title, 'Refreshed');
			verify(mockRepo.fetchBlogById('1')).called(2);
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

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			when(mockRepo.fetchBlogById('1')).thenThrow(Exception('Refetch failed'));

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
		});

		test('returns updated data after refetch', () async {
			final now = DateTime.now().toIso8601String();
			final blog1 = models.BlogPost(
				id: '1',
				title: 'Version 1',
				content: 'Content 1',
				createdAt: now,
			);
			final blog2 = models.BlogPost(
				id: '1',
				title: 'Version 2',
				content: 'Content 2',
				createdAt: now,
			);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog1);

			final provider = editBlogProvider('1');
			await container.read(provider.future);

			when(mockRepo.fetchBlogById('1')).thenAnswer((_) async => blog2);

			final notifier = container.read(provider.notifier);
			await notifier.refetchBlog();

			final state = await container.read(provider.future);
			expect(state!.title, 'Version 2');
			expect(state.content, 'Content 2');
		});
	});
}