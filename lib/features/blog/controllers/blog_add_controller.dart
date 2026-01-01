import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:flutter_blog_app/models/images.dart';
import 'package:flutter_blog_app/models/blog_posts.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/repositories/index.dart' as common_repositories;

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';

final log = Logger('CreateBlogController');

final createBlogProvider = NotifierProvider<CreateBlogController, AsyncValue<void>>(
	CreateBlogController.new,
);

class CreateBlogController extends Notifier<AsyncValue<void>> {
	late final common_repositories.BlogRepository _repository;

	@override
	AsyncValue<void> build() {
		_repository = ref.read(common_repositories.blogRepositoryProvider);
		return const AsyncValue.data(null);
	}

	Future<void> createBlog({
		required String content,
		List<File>? imageFiles,
	}) async {
		state = const AsyncValue.loading();

		state = await AsyncValue.guard(() async {
			final String blogId = const Uuid().v4();
      		final now = DateTime.now().toIso8601String();

			final blog = BlogPost(
				id: blogId,
				title: '',
				content: content,
				images: const [], // empty for now
				createdAt: now,
			);

			final List<Images> images = [];
			if (imageFiles != null) {
				for (final file in imageFiles) {
					final compressedBytes = await common_utils.compressImage(file);
					final base64Image = base64Encode(compressedBytes);

					images.add(
						Images(
							id: const Uuid().v4(),
							blogId: blogId,
							image: base64Image, // Store as base64 string
							createdAt: now,
						),
					);
				}
			}

			await _repository.addBlog(
				blog: blog,
				images: images,
			);

			// this is to invalidate the current homeViewProvider
			ref.invalidate(homeViewProvider);
		});
	}
}
