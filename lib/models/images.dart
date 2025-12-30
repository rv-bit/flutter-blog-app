import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' as widgets;

class Images {
	final String id;
	final String blogId;
	final String image;
	final String createdAt;

	Images({
		required this.id,
		required this.blogId,
		required this.image,
		required this.createdAt
	});

	factory Images.fromMap(Map<String, dynamic> map) => Images(
		id: map['id'],
		blogId: map['blog_id'],
		image: base64Encode(map['image'] as Uint8List),
		createdAt: map['created_at']
	);

	Map<String, dynamic> toMap() => {
		'id': id,
		'blog_id': blogId,
		'image': base64Decode(image),
		'created_at': createdAt
	};

	widgets.Image toImageWidget() => widgets.Image.memory(base64Decode(image));
	Uint8List toBytes() => base64Decode(image);

	static List<String> getImagesForBlogId(String blogId, List<Images> allImages) {
		return allImages.where((img) => img.blogId == blogId).map((img) => img.image).toList();
	}

	static Map<String, List<String>> groupByBlog(
		List<Images> images,
	) {
		final Map<String, List<String>> grouped = {};

		for (final img in images) {
			grouped.putIfAbsent(img.blogId, () => []).add(img.image);
		}
		return grouped;
	}
}