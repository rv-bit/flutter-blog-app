import 'dart:io';

class UpdateBlogPayload {
	final String blogId;
	final String content;
	final String title;

	// Images already in DB that should remain
	final List<String>? savedImages;
	// New images picked in UI (File paths)
	final List<File>? newImages;

	UpdateBlogPayload({
		required this.blogId,
		required this.content,
		required this.title,

		this.savedImages,
		this.newImages,
	});
}
