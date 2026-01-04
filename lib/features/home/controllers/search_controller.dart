import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/models/index.dart' as models;
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;

part 'generated/search_controller.g.dart';

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