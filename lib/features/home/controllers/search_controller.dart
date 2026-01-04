import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/models/index.dart' as models;
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

part 'search_controller.g.dart';

final log = Logger('SearchController');

// holds the current search query (search app bar  CupertinoTextField will update this)
@riverpod
class SearchQuery extends _$SearchQuery {
	@override
	String build() => '';

	void setQuery(String value) {
		state = value.trim();
	}

	void clear() {
		state = '';
	}
}

@riverpod
class SearchResults extends _$SearchResults {
	common_repositories.BlogRepository get _repository => ref.read(common_repositories.blogRepositoryProvider);

	common_widgets.BlogFilterOptions _currentFilter = common_widgets.BlogFilterOptions(
		sortBy: common_widgets.SortBy.createdAt,
		sortOrder: common_widgets.SortOrder.desc,
		datePosted: common_widgets.DatePosted.allTime,
	);

	common_widgets.BlogFilterOptions get currentFilter => _currentFilter;

	static const int _pageSize = 10;
	int _offset = 0;
	bool _hasMore = true;
	bool _isLoadingMore = false;

	bool get hasMore => _hasMore;
	bool get isLoadingMore => _isLoadingMore;

	@override
	Future<List<models.BlogPost>> build(String query) async {
		final trimmedQuery = query.trim();
		_offset = 0;
		_hasMore = true;

		if (trimmedQuery.isEmpty) return [];

		final blogs = await _repository.searchBlogs(
			trimmedQuery,
			limit: _pageSize,
			offset: 0,
		);

		_offset = blogs.length;
		_hasMore = blogs.length == _pageSize;

		return blogs;
	}

	void applyFilters(common_widgets.BlogFilterOptions options) async {
		_currentFilter = options; // save current filter
		
		// Reset and refetch with new filters
		_offset = 0;
		_hasMore = true;
		
		state = const AsyncValue.loading();
		
		try {
			final blogs = await _repository.searchBlogs(
				query,
				limit: _pageSize,
				offset: 0,
			);
			
			_offset = blogs.length;
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

	Future<void> loadMore() async {
		if (_isLoadingMore || !_hasMore || query.isEmpty) return;

		_isLoadingMore = true;
		final current = state.value ?? [];

		try {
			final next = await _repository.searchBlogs(
				query,
				limit: _pageSize,
				offset: _offset,
			);

			if (next.length < _pageSize) _hasMore = false;
			_offset += next.length;

			state = AsyncValue.data([...current, ...next]);
		} catch (error, stackTrace) {
			log.severe('Error loading more results', error, stackTrace);
		} finally {
			_isLoadingMore = false;
		}
	}

	Future<void> refresh() async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() => build(query));
	}
}