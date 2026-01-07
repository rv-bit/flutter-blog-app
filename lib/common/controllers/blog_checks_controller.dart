
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;

part 'blog_checks_controller.g.dart';

@riverpod
Future<bool> blogExists(ref, String id) async {
	final repo = ref.read(common_repositories.blogRepositoryProvider);
	final blog = await repo.fetchBlogById(id);
	return blog != null;
}