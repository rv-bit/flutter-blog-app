class BlogPost {
	final String id;
	final String title;
	final String content;
	final String? image;
	final String createdAt;
	final String? updatedAt;
	final String? deletedAt;
	final bool isDeleted;

	BlogPost({
		required this.id,
		required this.title,
		required this.content,
		required this.createdAt,
		this.image,
		this.updatedAt,
		this.deletedAt,
		this.isDeleted = false,
	});

	factory BlogPost.fromMap(Map<String, dynamic> map) => BlogPost(
		id: map['id'],
		title: map['title'],
		content: map['content'],
		createdAt: map['createdAt'],
		image: map['image'],
		updatedAt: map['updatedAt'],
		deletedAt: map['deletedAt'],
		isDeleted: map['isDeleted'] == 1,
	);

	Map<String, dynamic> toMap() => {
		'id': id,
		'title': title,
		'content': content,
		'created_at': createdAt,
		'image': image,
		'updated_at': updatedAt,
		'deleted_at': deletedAt,
		'isDeleted': isDeleted ? 1 : 0,
	};
}
