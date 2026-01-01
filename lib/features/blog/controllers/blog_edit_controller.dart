import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_blog_app/models/blog_posts.dart';
import 'package:flutter_blog_app/models/payloads/update_blog_post_payload.dart';

import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;

part 'generators/blog_edit_controller.g.dart';

final log = Logger('EditBlogController');

@riverpod
class EditBlog extends _$EditBlog {
	common_repositories.BlogRepository get _repository => ref.read(common_repositories.blogRepositoryProvider);

	@override
	Future<BlogPost?> build(String id) async {
		final blog = await _repository.fetchBlogById(id);
		return blog;
	}

	Future<void> updateBlog(UpdateBlogPayload payload) async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			await _repository.updateBlog(payload);
    		return _repository.fetchBlogById(payload.blogId);
		});
	}

	Future<void> deleteBlog() async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			await _repository.deleteBlog(id);
			return null;
		});
	}

	Future<void> refetchBlog() async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() => _repository.fetchBlogById(id));
	}
}