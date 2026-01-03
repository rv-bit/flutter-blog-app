import './images.dart';

class BlogPost {
	final String id;
	final String content;
	final String title;
	final List<Images>? images;
	final String createdAt;
	final String? updatedAt;

	BlogPost({
		required this.id,
		required this.content,
		required this.title,
		required this.createdAt,
		this.images,
		this.updatedAt,
	});

	// Convenience getter for UI rendering
	List<String>? get imageData => images?.map((img) => img.image).toList();
	
	// Convenience getter for IDs (useful for deletion)
	List<String>? get imageIds => images?.map((img) => img.id).toList();

	factory BlogPost.fromMap(Map<String, dynamic> map) => BlogPost(
		id: map['id'],
		content: map['content'],
		title: map['title'],
		createdAt: map['created_at'],
		images: const [],
		updatedAt: map['updated_at'],
	);

	factory BlogPost.fromMapWithImages(Map<String, dynamic> map, List<Images> imageModels) {
		return BlogPost(
			id: map['id'],
			content: map['content'],
			title: map['title'],
			createdAt: map['created_at'],
			images: imageModels,
			updatedAt: map['updated_at'],
		);
	}

	Map<String, dynamic> toMap() => {
		'id': id,
		'content': content,
		'title': title,
		'created_at': createdAt,
		'updated_at': updatedAt,
	};
}
