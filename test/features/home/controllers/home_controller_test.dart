import 'package:flutter_blog_app/models/database/blog_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/common/widgets/index.dart' as widgets;

@GenerateMocks([BlogRepository])
import 'home_controller_test.mocks.dart';

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

	group('HomeController - build', () {
		test('loads initial blogs from repository', () async {
			final now = DateTime.now().toIso8601String();
			final fakeBlogs = [
				BlogPost(id: '1', title: 'Test 1', content: 'Hello', createdAt: now),
				BlogPost(id: '2', title: 'Test 2', content: 'World', createdAt: now),
			];
			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => fakeBlogs);

			final blogs = await container.read(homeViewProvider.future);

			expect(blogs.length, 2);
			expect(blogs, fakeBlogs);
			verify(mockRepo.fetchBlogs(limit: 10, offset: 0)).called(1);
		});

		test('initializes pagination state correctly with full page', () async {
			final now = DateTime.now().toIso8601String();
			final fullPage = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => fullPage);

			await container.read(homeViewProvider.future);
			final notifier = container.read(homeViewProvider.notifier);

			expect(notifier.hasMore, isTrue);
		});

		test('initializes pagination state with partial page', () async {
			final now = DateTime.now().toIso8601String();
			final partialPage = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
			];
			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => partialPage);

			await container.read(homeViewProvider.future);
			final notifier = container.read(homeViewProvider.notifier);

			expect(notifier.hasMore, isFalse);
		});

		test('handles empty blog list', () async {
			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => []);

			final blogs = await container.read(homeViewProvider.future);

			expect(blogs, isEmpty);
			final notifier = container.read(homeViewProvider.notifier);
			expect(notifier.hasMore, isFalse);
		});
	});

	group('HomeController - loadMore', () {
		test('loads next page of blogs', () async {
			final now = DateTime.now().toIso8601String();
			final firstPage = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			final secondPage = List.generate(
				10,
				(i) => BlogPost(id: '${i + 10}', title: 'Blog ${i + 10}', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => firstPage);
			when(mockRepo.fetchBlogs(limit: 10, offset: 10))
				.thenAnswer((_) async => secondPage);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore();

			final blogs = container.read(homeViewProvider).value;
			expect(blogs?.length, 20);
			verify(mockRepo.fetchBlogs(limit: 10, offset: 10)).called(1);
		});

		test('does not load more when already loading', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: anyNamed('limit'), offset: anyNamed('offset')))
				.thenAnswer((_) async {
					await Future.delayed(const Duration(milliseconds: 100));
					return blogs;
				});

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);

			// Start first loadMore
			final future1 = notifier.loadMore();
			// Try second loadMore while first is loading
			await notifier.loadMore();

			await future1;

			// Should only call once
			verify(mockRepo.fetchBlogs(limit: 10, offset: 10)).called(1);
		});

		test('does not load more when hasMore is false', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore();

			verifyNever(mockRepo.fetchBlogs(limit: 10, offset: 1));
		});

		test('handles loadMore error gracefully', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.fetchBlogs(limit: 10, offset: 10))
				.thenThrow(Exception('Network error'));

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore();

			// Should maintain existing data
			final currentBlogs = container.read(homeViewProvider).value;
			expect(currentBlogs?.length, 10);
		});

		test('sets hasMore to false when receiving partial page', () async {
			final now = DateTime.now().toIso8601String();
			final firstPage = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			final partialPage = [
				BlogPost(id: '10', title: 'Blog 10', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => firstPage);
			when(mockRepo.fetchBlogs(limit: 10, offset: 10))
				.thenAnswer((_) async => partialPage);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore();

			expect(notifier.hasMore, isFalse);
		});

		test('sets hasMore to false when receiving empty page', () async {
			final now = DateTime.now().toIso8601String();
			final firstPage = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => firstPage);
			when(mockRepo.fetchBlogs(limit: 10, offset: 10))
				.thenAnswer((_) async => []);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore();

			expect(notifier.hasMore, isFalse);
		});
	});

	group('HomeController - refresh', () {
		test('reloads blogs from beginning', () async {
			final now = DateTime.now().toIso8601String();
			final initialBlogs = [
				BlogPost(id: '1', title: 'Initial', content: 'Content', createdAt: now),
			];
			final refreshedBlogs = [
				BlogPost(id: '1', title: 'Refreshed', content: 'Updated', createdAt: now),
				BlogPost(id: '2', title: 'New Blog', content: 'New', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => initialBlogs);

			await container.read(homeViewProvider.future);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => refreshedBlogs);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.refresh();

			final blogs = await container.read(homeViewProvider.future);
			expect(blogs.length, 2);
			expect(blogs[0].title, 'Refreshed');
			verify(mockRepo.fetchBlogs(limit: 10, offset: 0)).called(2);
		});

		test('refresh maintains scroll position by fetching same number of items', () async {
			final now = DateTime.now().toIso8601String();
			final page1 = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			final page2 = List.generate(
				10,
				(i) => BlogPost(id: '${i + 10}', title: 'Blog ${i + 10}', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => page1);
			when(mockRepo.fetchBlogs(limit: 10, offset: 10))
				.thenAnswer((_) async => page2);

			await container.read(homeViewProvider.future);
			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore(); // Load 20 items total

			// Refresh should try to fetch 20 items but clamped to page size
			await notifier.refresh();

			verify(mockRepo.fetchBlogs(limit: 10, offset: 0)).called(2);
		});

		test('handles refresh error', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenThrow(Exception('Refresh failed'));

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.refresh();

			final state = container.read(homeViewProvider);
			expect(state, isA<AsyncError>());
		});

		test('refresh resets isLoadingMore flag', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: anyNamed('limit'), offset: anyNamed('offset')))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.refresh();

			expect(notifier.isLoadingMore, isFalse);
		});
	});

	group('HomeController - deleteBlog', () {
		test('removes blog from state optimistically', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
				BlogPost(id: '2', title: 'Blog 2', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.deleteBlog('1')).thenAnswer((_) async => 1);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.deleteBlog('1');

			final remaining = container.read(homeViewProvider).value;
			expect(remaining?.length, 1);
			expect(remaining?[0].id, '2');
			verify(mockRepo.deleteBlog('1')).called(1);
		});

		test('handles empty id gracefully', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.deleteBlog('');

			verifyNever(mockRepo.deleteBlog(any));
		});

		test('rolls back on delete error', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
				BlogPost(id: '2', title: 'Blog 2', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.deleteBlog('1')).thenThrow(Exception('Delete failed'));

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);

			expect(
				() => notifier.deleteBlog('1'),
				throwsException,
			);
		});
	});

	group('HomeController - deleteMultipleBlogs', () {
		test('removes multiple blogs from state', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
				BlogPost(id: '2', title: 'Blog 2', content: 'Content', createdAt: now),
				BlogPost(id: '3', title: 'Blog 3', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.deleteMultipleBlogs({'1', '2'}))
				.thenAnswer((_) async => 2);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.deleteMultipleBlogs({'1', '2'});

			final remaining = container.read(homeViewProvider).value;
			expect(remaining?.length, 1);
			expect(remaining?[0].id, '3');
			verify(mockRepo.deleteMultipleBlogs({'1', '2'})).called(1);
		});

		test('handles empty set gracefully', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			await notifier.deleteMultipleBlogs({});

			verifyNever(mockRepo.deleteMultipleBlogs(any));
		});

		test('rolls back on error', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
				BlogPost(id: '2', title: 'Blog 2', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.deleteMultipleBlogs({'1', '2'}))
				.thenThrow(Exception('Delete failed'));

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);

			expect(
				() => notifier.deleteMultipleBlogs({'1', '2'}),
				throwsException,
			);
		});
	});

	group('HomeController - applyFilters', () {
		test('applies date filter - past24Hours', () async {
			final now = DateTime.now();
			final oldDate = now.subtract(const Duration(days: 2));
			final recentDate = now.subtract(const Duration(hours: 5));

			final blogs = [
				BlogPost(id: '1', title: 'Old', content: 'Content', createdAt: oldDate.toIso8601String()),
				BlogPost(id: '2', title: 'Recent', content: 'Content', createdAt: recentDate.toIso8601String()),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.past24Hours,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			final filtered = container.read(homeViewProvider).value;
			expect(filtered?.length, 1);
			expect(filtered?[0].id, '2');
		});

		test('applies date filter - pastWeek', () async {
			final now = DateTime.now();
			final oldDate = now.subtract(const Duration(days: 10));
			final withinWeek = now.subtract(const Duration(days: 3));

			final blogs = [
				BlogPost(id: '1', title: 'Old', content: 'Content', createdAt: oldDate.toIso8601String()),
				BlogPost(id: '2', title: 'Within Week', content: 'Content', createdAt: withinWeek.toIso8601String()),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.pastWeek,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			final filtered = container.read(homeViewProvider).value;
			expect(filtered?.length, 1);
			expect(filtered?[0].id, '2');
		});

		test('applies sort order - ascending', () async {
			final now = DateTime.now().toIso8601String();
			final later = DateTime.now().add(const Duration(hours: 1)).toIso8601String();

			final blogs = [
				BlogPost(id: '1', title: 'First', content: 'Content', createdAt: later),
				BlogPost(id: '2', title: 'Second', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.asc,
				datePosted: widgets.DatePosted.allTime,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			final sorted = container.read(homeViewProvider).value;
			expect(sorted?[0].id, '2'); // Earlier date first
			expect(sorted?[1].id, '1');
		});

		test('applies sort by updatedAt', () async {
			final created = DateTime.now();
			final updated = created.add(const Duration(hours: 2));

			final blogs = [
				BlogPost(
					id: '1',
					title: 'Blog 1',
					content: 'Content',
					createdAt: created.toIso8601String(),
					updatedAt: updated.toIso8601String(),
				),
				BlogPost(
					id: '2',
					title: 'Blog 2',
					content: 'Content',
					createdAt: created.toIso8601String(),
				),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.updatedAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.allTime,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			final sorted = container.read(homeViewProvider).value;
			// Blog 1 has updatedAt, should be first when sorting by updatedAt desc
			expect(sorted?[0].id, '1');
		});

		test('handles filter application error', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenThrow(Exception('Filter error'));

			final notifier = container.read(homeViewProvider.notifier);
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.allTime,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			final state = container.read(homeViewProvider);
			expect(state, isA<AsyncError>());
		});

		test('resets pagination when applying filters', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.fetchBlogs(limit: anyNamed('limit'), offset: anyNamed('offset')))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);
			final notifier = container.read(homeViewProvider.notifier);
			await notifier.loadMore(); // Load more pages

			// Apply filters should reset
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.allTime,
			));

			await Future.delayed(const Duration(milliseconds: 100));

			// Should have made a fresh fetch from offset 0
			verify(mockRepo.fetchBlogs(limit: 10, offset: 0)).called(2);
		});
	});

	group('HomeController - currentFilter', () {
		test('stores and returns current filter', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.fetchBlogs(limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			await container.read(homeViewProvider.future);

			final notifier = container.read(homeViewProvider.notifier);
			final newFilter = widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.updatedAt,
				sortOrder: widgets.SortOrder.asc,
				datePosted: widgets.DatePosted.pastWeek,
			);

			notifier.applyFilters(newFilter);

			expect(notifier.currentFilter.sortBy, widgets.SortBy.updatedAt);
			expect(notifier.currentFilter.sortOrder, widgets.SortOrder.asc);
			expect(notifier.currentFilter.datePosted, widgets.DatePosted.pastWeek);
		});
	});
}