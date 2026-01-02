import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carousel_slider/carousel_slider.dart';

class BlogListContent extends StatefulWidget {
	final Widget avatarWidget;
	final AsyncValue<dynamic> appDirAsync;

	final String content;
	final String username;
	final String time; // could be created_At, or updated_At
	final List<String> imageData; // the images base64

	final bool isEdited;

	const BlogListContent({
		super.key,
		
		required this.appDirAsync,
		required this.avatarWidget,

		required this.content,
		required this.username,
		required this.time,
		required this.imageData,
		
		required this.isEdited,
	});

	@override
	State<BlogListContent> createState() => _BlogListContentState();
}

class _BlogListContentState extends State<BlogListContent> with TickerProviderStateMixin {
	@override
	Widget build(BuildContext context) {
		final textStyle = DefaultTextStyle.of(context).style;

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				widget.avatarWidget,
				const SizedBox(width: 10),

				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisSize: MainAxisSize.min, // to shrink-wrap content
						children: [
							Row(
								crossAxisAlignment: CrossAxisAlignment.center,
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Expanded(
										child: Row(
											children: [
												Flexible(
													child: Text(
														widget.username,
														maxLines: 1,
														overflow: TextOverflow.ellipsis,
														style: textStyle.copyWith(fontWeight: FontWeight.bold),
													),
												),
												const SizedBox(width: 6),
												Text(
													widget.time,
													style: textStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
												),
											],
										),
									),
								],
							),

							SizedBox(
								child: Text(
									widget.content,
									maxLines: null,
									softWrap: true,
								),
							),

							if (widget.imageData.isNotEmpty)
								const SizedBox(height: 5),

								widget.appDirAsync.when(data: (dir) {
									return CarouselSlider(
										items: widget.imageData.map((base64String) {
											return Container(
												width: MediaQuery.of(context).size.width,
												margin: const EdgeInsets.symmetric(horizontal: 5),
												child: ClipRRect(
													borderRadius: BorderRadius.circular(8.0),
													child: Image.memory(
														base64Decode(base64String), 
														fit: BoxFit.cover,
														gaplessPlayback: true, // prevents flicker when change of state
													),
												)
											);
										}).toList(),
										options: CarouselOptions(
											height: 400,
											enableInfiniteScroll: false,
											scrollPhysics: const PageScrollPhysics(),
										),
									);
								},
								loading: () => const Padding(
								padding: EdgeInsets.symmetric(vertical: 16.0),
									child: Center(child: CircularProgressIndicator()),
								),
								error: (_, _) => const Icon(Icons.error)
							),
						],
					),
				),
			],
		);
	}
}