import 'package:flutter_blog_app/models/images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/models/index.dart';
import 'package:flutter_blog_app/common/dao/blog_dao.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
	return BlogRepository(dao: ref.read(blogDAOProvider));
});

class BlogRepository {
	final BlogDAO dao;

	BlogRepository({required this.dao});

	Future<List<BlogPost>> fetchBlogs({required int limit, required int offset}) async {
		final blogRows = await dao.getBlogPosts(limit: limit, offset: offset);

		if (blogRows.isEmpty) return [];

		final blogIds = blogRows.map((row) => row['id'] as String).toList();
		final imageRows = await dao.getImagesByBlogIds(blogIds);

		final images = imageRows.map(Images.fromMap).toList();
		final imageMap = Images.groupByBlog(images);

		return blogRows.map((blogMap) {
			final blogId = blogMap['id'];

			return BlogPost(
				id: blogId,
				images: imageMap[blogId] ?? const [], 
				content: blogMap['content'], 
				createdAt: blogMap['created_at'],
				updatedAt: blogMap['updated_at'],
				deletedAt: blogMap['deleted_at'],
				isDeleted: blogMap['is_deleted'] == 1,
			);
		}).toList();
	}

	Future<BlogPost?> fetchBlogById(String id) async {
		final blog = await dao.getBlog(id);
		if (blog == null) return null;

		final imageRows = await dao.getImagesByBlogId(id);
		final images = imageRows.map(Images.fromMap).toList();

		return BlogPost.fromMapWithImages(blog, images);
	}

	Future<void> addBlogWithImages({
		required BlogPost blog,
		required List<Images> images,
	}) async {
		await dao.insertBlogWithImages(
			blog: blog.toMap(),
			images: images.map((e) => e.toMap()).toList(),
		);
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
