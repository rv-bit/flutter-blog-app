import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_blog_app/models/index.dart' as models;
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;

part 'individual_blog_controller.g.dart';

final log = Logger('IndividualBlogController');

@riverpod
class IndividualBlog extends _$IndividualBlog {
	common_repositories.BlogRepository get _repository => ref.read(common_repositories.blogRepositoryProvider);

	@override
	Future<models.BlogPost?> build(String id) async {
		final blog = await _repository.fetchBlogById(id);
		return blog;
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