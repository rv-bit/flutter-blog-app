import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogListContent extends StatefulWidget {
	final Widget avatarWidget;
	final AsyncValue<dynamic> appDirAsync;

	final String content;
	final String username;
	final List<String>? imageData;

	const BlogListContent({
		super.key,
		
		required this.appDirAsync,
		required this.avatarWidget,

		required this.content,
		required this.username,

		this.imageData,
	});

	@override
	State<BlogListContent> createState() => _BlogListContentState();
}

class _BlogListContentState extends State<BlogListContent> with TickerProviderStateMixin {
	@override
	Widget build(BuildContext context) {
		final textStyle = DefaultTextStyle.of(context).style;

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: const EdgeInsets.only(right: 5, top: 5),
								child: widget.avatarWidget,
							),
							Expanded(
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											mainAxisSize: MainAxisSize.min,
											children: [
												Text(
													widget.username,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
													style: textStyle.copyWith(fontWeight: FontWeight.bold),
												),
												Text(
													'@${widget.username}',
													style: textStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
												),
											],
										),
									],
								),
							),
						],
					),

					Padding(
						padding: const EdgeInsets.only(top: 10),
						child: Text(
							widget.content,
							maxLines: null,
							softWrap: true,
						),
					),
				],
			),
		);
	}
}