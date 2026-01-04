import 'package:logging/logging.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/models/index.dart' as models;
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

final log = Logger('HomeController');

final homeViewProvider = AsyncNotifierProvider<HomeController, List<models.BlogPost>>(() {
	return HomeController();
});

class HomeController extends AsyncNotifier<List<models.BlogPost>> {
	common_repositories.BlogRepository get _repository => ref.read(common_repositories.blogRepositoryProvider);
	
	common_widgets.BlogFilterOptions _currentFilter = common_widgets.BlogFilterOptions(
		sortBy: common_widgets.SortBy.createdAt,
		sortOrder: common_widgets.SortOrder.desc,
		datePosted: common_widgets.DatePosted.allTime,
	);

	common_widgets.BlogFilterOptions get currentFilter => _currentFilter;

	static const int _pageSize = 10;
	int _currentOffset = 0;
	bool _hasMore = true;
	bool _isLoadingMore = false;

	bool get hasMore => _hasMore;
	bool get isLoadingMore => _isLoadingMore;

	@override
	Future<List<models.BlogPost>> build() async {
		_currentOffset = 0;
		_hasMore = true;
		
		final blogs = await _repository.fetchBlogs(
			limit: _pageSize,
			offset: 0,
		);

		_currentOffset = blogs.length;

		_hasMore = blogs.length == _pageSize;
		return blogs;
	}

	void applyFilters(common_widgets.BlogFilterOptions options) async {
		_currentFilter = options; // save current filter
		
		// Reset and refetch with new filters
		_currentOffset = 0;
		_hasMore = true;
		
		state = const AsyncValue.loading();
		
		try {
			final blogs = await _repository.fetchBlogs(
				limit: _pageSize,
				offset: 0,
			);
			
			_currentOffset = blogs.length;
			_hasMore = blogs.length == _pageSize;
			
			final filtered = _applyFilterLogic(blogs, options);
			
			state = AsyncValue.data(filtered);
		} catch (error, stackTrace) {
			log.severe('Error applying filters', error, stackTrace);
			state = AsyncValue.error(error, stackTrace);
		}
	}

	List<models.BlogPost> _applyFilterLogic(
		List<models.BlogPost> blogs, 
		common_widgets.BlogFilterOptions options
	) {
		final now = DateTime.now().toUtc();

		final filtered = blogs.where((blog) {
			final createdAt = DateTime.parse(
				options.sortBy == common_widgets.SortBy.createdAt 
					? blog.createdAt 
					: blog.updatedAt ?? blog.createdAt
			).toUtc();
			final diff = now.difference(createdAt);

			switch (options.datePosted) {
				case common_widgets.DatePosted.allTime:
					return true;
				case common_widgets.DatePosted.pastHour:
					return diff.inMinutes < 60;
				case common_widgets.DatePosted.past24Hours:
					return diff.inHours < 24;
				case common_widgets.DatePosted.pastWeek:
					return diff.inDays < 7;
				case common_widgets.DatePosted.pastMonth:
					return diff.inDays < 30;
				case common_widgets.DatePosted.pastYear:
					return diff.inDays < 365;
			}
		}).toList();

		filtered.sort((a, b) {
			final keyA = options.sortBy == common_widgets.SortBy.createdAt
				? DateTime.parse(a.createdAt)
				: a.updatedAt != null
					? DateTime.parse(a.updatedAt!)
					: null;
			final keyB = options.sortBy == common_widgets.SortBy.createdAt
				? DateTime.parse(b.createdAt)
				: b.updatedAt != null
					? DateTime.parse(b.updatedAt!)
					: null;

			if (keyA == null && keyB == null) return 0;
			if (keyA == null) return 1;
			if (keyB == null) return -1;

			return options.sortOrder == common_widgets.SortOrder.asc
				? keyA.compareTo(keyB)
				: keyB.compareTo(keyA);
		});

		return filtered;
	}


	// Load more blogs (pagination)
	Future<void> loadMore() async {
		if (_isLoadingMore || !_hasMore) return;
		
		_isLoadingMore = true;
		
		final currentBlogs = state.value ?? [];
		
		try {
			final newBlogs = await _repository.fetchBlogs(
				limit: _pageSize,
				offset: _currentOffset,
			);

			if (newBlogs.isEmpty || newBlogs.length < _pageSize) {
				_hasMore = false;
			}
			
			_currentOffset += newBlogs.length;
			
			state = AsyncValue.data([...currentBlogs, ...newBlogs]);
		} catch (e) {
			// Keep existing data, just log the error
			log.severe('Error loading more blogs: $e');
		} finally {
			_isLoadingMore = false;
		}
	}

	Future<void> refresh() async {
		state = const AsyncValue.loading();
		
		// Remember how many items were loaded before refresh
		final currentCount = state.value?.length ?? _pageSize;
		final itemsToFetch = currentCount.clamp(_pageSize, _pageSize);
		
		_isLoadingMore = false;
		
		state = await AsyncValue.guard(() async {
			final blogs = await _repository.fetchBlogs(
				limit: itemsToFetch,
				offset: 0,
			);

			_currentOffset = blogs.length;
			_hasMore = blogs.length == itemsToFetch;
			return blogs;
		});
	}

	Future<void> deleteBlog(String id) async {
		if (id.isEmpty) return;

		final current = state.value ?? [];

		state = AsyncValue.data(
			current.where((b) => b.id != id).toList(),
		);

		try {
			await _repository.deleteBlog(id);
		} catch (e, stack) {
			log.severe('❌ Error deleting blog', e, stack);
			ref.invalidateSelf(); // rollback by refetch
			rethrow;
		}
	}

	Future<void> deleteMultipleBlogs(Set<String> ids) async {
		if (ids.isEmpty) return;

		final current = state.value ?? [];

		state = AsyncValue.data(
			current.where((b) => !ids.contains(b.id)).toList(),
		);

		try {
			await _repository.deleteMultipleBlogs(ids);
		} catch (e, stack) {
			log.severe('❌ Error deleting blog', e, stack);
			ref.invalidateSelf(); // rollback by refetch
			rethrow;
		}
	}
}