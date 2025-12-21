import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/models/models.dart';
import 'package:flutter_blog_app/common/dao/blog_dao.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
	return BlogRepository(dao: ref.watch(blogDAOProvider));
});

class BlogRepository {
	final BlogDAO dao;

	BlogRepository({required this.dao});

	Future<List<BlogPost>> fetchBlogs() async {
		final rows = await dao.getBlogPosts();
		return rows.map(BlogPost.fromMap).toList();
	}

	Future<BlogPost?> fetchBlogById(String id) async {
		final row = await dao.getBlog(id);
		if (row != null) {
			return BlogPost.fromMap(row);
		}
		return null;
	}

	Future<void> addBlog(BlogPost blog) async {
		await dao.insertBlogPost(blog.toMap());
	}

	Future<void> updateBlog(BlogPost blog) async {
		await dao.updateBlog(blog.id, blog.toMap());
	}

	Future<void> deleteBlog(String id) async {
		await dao.deleteBlog(id);
	}

	Future<void> deleteMultipleBlogs(List<String> ids) async {
		await dao.deleteMultiple(ids);
	}

	Future<List<BlogPost>> searchBlogs(String query) async {
		final rows = await dao.searchBlogs(query);
		return rows.map(BlogPost.fromMap).toList();
	}
}
