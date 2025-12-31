import 'package:flutter_blog_app/models/images.dart';

class BlogPost {
	final String id;
	final String content;
	final List<String> images;
	final String createdAt;
	final String? updatedAt;
	final String? deletedAt;
	final bool? isDeleted;

	BlogPost({
		required this.id,
		required this.content,
		required this.createdAt,
		required this.images,
		this.updatedAt,
		this.deletedAt,
		this.isDeleted = false,
	});

	factory BlogPost.fromMap(Map<String, dynamic> map) => BlogPost(
		id: map['id'],
		content: map['content'],
		createdAt: map['created_at'],
		images: const [],
		updatedAt: map['updated_at'],
		deletedAt: map['deleted_at'],
		isDeleted: map['is_deleted'] == 1,
	);

	factory BlogPost.fromMapWithImages(Map<String, dynamic> map, List<Images> imageModels) {
		final imageUrls = imageModels.map((e) => e.image).toList();

		return BlogPost(
			id: map['id'],
			content: map['content'],
			createdAt: map['created_at'],
			images: imageUrls,
			updatedAt: map['updated_at'],
			deletedAt: map['deleted_at'],
			isDeleted: map['is_deleted'] == 1,
		);
	}

	Map<String, dynamic> toMap() => {
		'id': id,
		'content': content,
		'created_at': createdAt,
		'updated_at': updatedAt,
		'deleted_at': deletedAt,
		'is_deleted': isDeleted ?? 0,
	};
}
