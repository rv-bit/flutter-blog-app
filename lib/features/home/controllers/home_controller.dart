import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/models/blog_posts.dart';
import 'package:flutter_blog_app/common/repositories/index.dart';

final log = Logger('HomeController');

final homeViewProvider = AsyncNotifierProvider<HomeController, List<BlogPost>>(() {
	return HomeController();
});

final refreshBlogsProvider = FutureProvider((ref) {
	final blogController = ref.watch(homeViewProvider.notifier);
	return blogController.refresh();
});

final loadMoreBlogsProvider = FutureProvider((ref) {
	final blogController = ref.watch(homeViewProvider.notifier);
	return blogController.loadMore();
});

final deleteBlogProvider = FutureProvider.family((ref, String id) {
	final blogController = ref.watch(homeViewProvider.notifier);
	return blogController.deleteBlog(id);
});

class HomeController extends AsyncNotifier<List<BlogPost>> {
	BlogRepository get _repository => ref.read(blogRepositoryProvider);
	
	static const int _pageSize = 10;
	int _currentOffset = 0;
	bool _hasMore = true;
	bool _isLoadingMore = false;

	@override
	Future<List<BlogPost>> build() async {
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

	bool get hasMore => _hasMore;
	bool get isLoadingMore => _isLoadingMore;

	// Delete a blog post by id and refresh
	Future<void> deleteBlog(String id) async {
		await _repository.deleteBlog(id);
		await refresh();
	}
}