import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blog_app/features/home/controllers/search_controller.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/models/index.dart' as models;
import 'package:flutter_blog_app/common/widgets/index.dart' as widgets;

@GenerateMocks([BlogRepository])
import 'search_controller_test.mocks.dart';

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

	group('SearchQuery', () {
		test('initial state is empty string', () {
			final query = container.read(searchQueryProvider);
			expect(query, '');
		});

		test('setQuery updates state', () {
			final notifier = container.read(searchQueryProvider.notifier);

			notifier.setQuery('flutter');

			final query = container.read(searchQueryProvider);
			expect(query, 'flutter');
		});

		test('setQuery trims whitespace', () {
			final notifier = container.read(searchQueryProvider.notifier);

			notifier.setQuery('  flutter  ');

			final query = container.read(searchQueryProvider);
			expect(query, 'flutter');
		});

		test('clear resets state to empty string', () {
			final notifier = container.read(searchQueryProvider.notifier);

			notifier.setQuery('flutter');
			expect(container.read(searchQueryProvider), 'flutter');

			notifier.clear();
			expect(container.read(searchQueryProvider), '');
		});

		test('setQuery with empty string', () {
			final notifier = container.read(searchQueryProvider.notifier);

			notifier.setQuery('flutter');
			notifier.setQuery('');

			final query = container.read(searchQueryProvider);
			expect(query, '');
		});

		test('setQuery handles special characters', () {
			final notifier = container.read(searchQueryProvider.notifier);

			notifier.setQuery('flutter & dart');

			final query = container.read(searchQueryProvider);
			expect(query, 'flutter & dart');
		});
	});

	group('SearchResults - build', () {
		test('returns empty list for empty query', () async {
			final provider = searchResultsProvider('');
			final results = await container.read(provider.future);

			expect(results, isEmpty);
			verifyNever(mockRepo.searchBlogs(any, limit: anyNamed('limit'), offset: anyNamed('offset')));
		});

		test('returns empty list for whitespace query', () async {
			final provider = searchResultsProvider('   ');
			final results = await container.read(provider.future);

			expect(results, isEmpty);
		});

		test('returns search results for valid query', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				models.BlogPost(id: '1', title: 'Flutter Tutorial', content: 'Learn Flutter', createdAt: now),
				models.BlogPost(id: '2', title: 'Flutter Tips', content: 'Tips and tricks', createdAt: now),
			];

			when(mockRepo.searchBlogs('flutter', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('flutter');
			final results = await container.read(provider.future);

			expect(results.length, 2);
			expect(results[0].title, 'Flutter Tutorial');
			expect(results[1].title, 'Flutter Tips');
			verify(mockRepo.searchBlogs('flutter', limit: 10, offset: 0)).called(1);
		});

		test('initializes pagination state correctly', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => models.BlogPost(
					id: '$i',
					title: 'Blog $i',
					content: 'Content $i',
					createdAt: now,
				),
			);

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			final notifier = container.read(provider.notifier);

			await container.read(provider.future);

			expect(notifier.hasMore, isTrue); // Full page means more might exist
		});

		test('sets hasMore to false when results less than page size', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				models.BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			expect(notifier.hasMore, isFalse);
		});
	});

	group('SearchResults - loadMore', () {
		test('loads next page of results', () async {
			final now = DateTime.now().toIso8601String();
			final firstPage = List.generate(
				10,
				(i) => models.BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			final secondPage = List.generate(
				10,
				(i) => models.BlogPost(id: '${i + 10}', title: 'Blog ${i + 10}', content: 'Content', createdAt: now),
			);

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => firstPage);
			when(mockRepo.searchBlogs('test', limit: 10, offset: 10))
				.thenAnswer((_) async => secondPage);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.loadMore();

			final results = await container.read(provider.future);
			expect(results.length, 20);
			expect(results[19].id, '19');
			verify(mockRepo.searchBlogs('test', limit: 10, offset: 10)).called(1);
		});

		test('does not load more when hasMore is false', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				models.BlogPost(id: '1', title: 'Blog 1', content: 'Content', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.loadMore();

			// Should not make additional call because hasMore is false
			verifyNever(mockRepo.searchBlogs('test', limit: 10, offset: 1));
		});

		test('does not load more when query is empty', () async {
			final provider = searchResultsProvider('');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.loadMore();

			verifyNever(mockRepo.searchBlogs(any, limit: anyNamed('limit'), offset: anyNamed('offset')));
		});

		test('handles loadMore error gracefully', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => models.BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);
			when(mockRepo.searchBlogs('test', limit: 10, offset: 10))
				.thenThrow(Exception('Load more failed'));

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.loadMore();

			// State should still contain initial data
			final results = container.read(provider).value;
			expect(results?.length, 10);
		});

		test('sets hasMore to false when receiving partial page', () async {
			final now = DateTime.now().toIso8601String();
			final firstPage = List.generate(
				10,
				(i) => models.BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);
			final partialPage = [
				models.BlogPost(id: '10', title: 'Blog 10', content: 'Content', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => firstPage);
			when(mockRepo.searchBlogs('test', limit: 10, offset: 10))
				.thenAnswer((_) async => partialPage);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			await notifier.loadMore();

			expect(notifier.hasMore, isFalse);
		});
	});

	group('SearchResults - refresh', () {
		test('refreshes search results', () async {
			final now = DateTime.now().toIso8601String();
			final initialBlogs = [
				models.BlogPost(id: '1', title: 'Initial', content: 'Content', createdAt: now),
			];
			final refreshedBlogs = [
				models.BlogPost(id: '1', title: 'Refreshed', content: 'Updated', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => initialBlogs);

			final provider = searchResultsProvider('test');
			final initial = await container.read(provider.future);
			expect(initial[0].title, 'Initial');

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => refreshedBlogs);

			final notifier = container.read(provider.notifier);
			await notifier.refresh();

			final refreshed = await container.read(provider.future);
			expect(refreshed[0].title, 'Refreshed');
			verify(mockRepo.searchBlogs('test', limit: 10, offset: 0)).called(2);
		});

		test('refresh handles error', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				models.BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenThrow(Exception('Refresh failed'));

			final notifier = container.read(provider.notifier);
			await notifier.refresh();

			final state = container.read(provider);
			expect(state, isA<AsyncError>());
		});
	});

	group('SearchResults - applyFilters', () {
		test('stores current filter options', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = [
				models.BlogPost(id: '1', title: 'Blog', content: 'Content', createdAt: now),
			];

			when(mockRepo.searchBlogs('test', limit: 10, offset: 0))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
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

		test('resets pagination state when applying filters', () async {
			final now = DateTime.now().toIso8601String();
			final blogs = List.generate(
				10,
				(i) => models.BlogPost(id: '$i', title: 'Blog $i', content: 'Content', createdAt: now),
			);

			when(mockRepo.searchBlogs('test', limit: 10, offset: anyNamed('offset')))
				.thenAnswer((_) async => blogs);

			final provider = searchResultsProvider('test');
			await container.read(provider.future);

			final notifier = container.read(provider.notifier);
			
			// Load more to change offset
			await notifier.loadMore();
			
			// Apply filters should reset and make a new call from offset 0
			notifier.applyFilters(widgets.BlogFilterOptions(
				sortBy: widgets.SortBy.createdAt,
				sortOrder: widgets.SortOrder.desc,
				datePosted: widgets.DatePosted.allTime,
			));

			// Wait a bit for async operation
			await Future.delayed(const Duration(milliseconds: 100));

			// Should have called with offset 0 after initial build and after filter
			verify(mockRepo.searchBlogs('test', limit: 10, offset: 0)).called(greaterThanOrEqualTo(2));
		});
	});
}