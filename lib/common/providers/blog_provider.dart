import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/models/blog_posts.dart';
import 'package:flutter_blog_app/common/repositories/repositories.dart';

final blogProvider = AsyncNotifierProvider<BlogNotifier, List<BlogPost>>(() {
	return BlogNotifier();
});

class BlogNotifier extends AsyncNotifier<List<BlogPost>> {
	late final BlogRepository _repository;

	// This method is called when the notifier is first created, it should return the initial state, which is a list of BlogPost objects.
	@override
	Future<List<BlogPost>> build() async {
		_repository = ref.read(blogRepositoryProvider);
		final blogs = await _repository.fetchBlogs();
		return blogs;
	}

	// Add a new blog post and refresh the state
	Future<void> addBlog(BlogPost item) async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			await _repository.addBlog(item);
			return await _repository.fetchBlogs();
		});
	}

	// Delete a blog post by id and refresh the state
	Future<void> deleteBlog(String id) async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			await _repository.deleteBlog(id);
			return await _repository.fetchBlogs();
		});
	}
}