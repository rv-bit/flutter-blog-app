import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/models/index.dart' as common_models;

import 'package:flutter_blog_app/common/dao/blog_dao.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
	return BlogRepository(dao: ref.read(blogDAOProvider));
});

class BlogRepository {
	final BlogDAO dao;

	BlogRepository({required this.dao});

	Future<List<common_models.BlogPost>> fetchBlogs({required int limit, required int offset}) async {
		final blogRows = await dao.getBlogPosts(limit: limit, offset: offset);

		if (blogRows.isEmpty) return [];

		final blogIds = blogRows.map((row) => row['id'] as String).toList();
		final imageRows = await dao.getImagesByBlogIds(blogIds);

		final images = imageRows.map(common_models.Images.fromMap).toList();
		final imageMap = common_models.Images.groupByBlog(images);

		return blogRows.map((blogMap) {
			final blogId = blogMap['id'];

			return common_models.BlogPost(
				id: blogId,
				images: imageMap[blogId] ?? const [], 
				title: blogMap['title'],
				content: blogMap['content'], 
				createdAt: blogMap['created_at'],
				updatedAt: blogMap['updated_at'],
			);
		}).toList();
	}

	Future<common_models.BlogPost?> fetchBlogById(String id) async {
		final blog = await dao.getBlog(id);
		if (blog == null) return null;

		final imageRows = await dao.getImagesByBlogId(id);
		final images = imageRows.map(common_models.Images.fromMap).toList();

		return common_models.BlogPost.fromMapWithImages(blog, images);
	}

	Future<void> addBlog({
		required common_models.BlogPost blog,
		required List<common_models.Images>? images,
	}) async {
		await dao.insertBlog(
			blog: blog.toMap(),
			images: images?.map((e) => e.toMap()).toList(),
		);
	}

	Future<void> updateBlog(common_models.UpdateBlogPayload payload) async {
		final now = DateTime.now().toIso8601String();

		await dao.updateBlog(
			payload.blogId,
			{
				'title': payload.title,
				'content': payload.content,
				'updated_at': now,
			},
		);

		if (payload.savedImages != null) {
			await dao.deleteSavedImages(
				blogId: payload.blogId,
				savedImages: payload.savedImages!,
			);
		}

		if (payload.newImages != null) {
			for (final file in payload.newImages!) {
				final imageId = const Uuid().v4();
				final compressedBytes = await common_utils.compressImage(file);
				final base64Image = base64Encode(compressedBytes);

				await dao.insertImage(
					common_models.Images(
						id: imageId,
						blogId: payload.blogId,
						image: base64Image,
						createdAt: now,
					).toMap(),
				);
			}
		}
	}


	Future<void> deleteBlog(String id) async {
		await dao.deleteBlog(id);
	}

	Future<void> deleteMultipleBlogs(Set<String> ids) async {
		await dao.deleteMultiple(ids);
	}

	Future<List<common_models.BlogPost>> searchBlogs(
		String query, 
		{
			required limit,
			required offset
		}
	) async {
		final rows = await dao.searchBlogs(query, limit: limit, offset: offset);
		return rows.map(common_models.BlogPost.fromMap).toList();
	}
}
