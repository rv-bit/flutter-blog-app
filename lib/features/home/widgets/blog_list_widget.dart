import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/models/blog_posts.dart';

import 'package:flutter_blog_app/features/home/widgets/blog_list_text_widget.dart';

class BlogList extends StatelessWidget {
	final ScrollController scrollController;
	final List<BlogPost> blogs;
	final AsyncValue<dynamic> appDirAsync;
	final double indicatorHeight;
	final ValueListenable<Widget?>? headerNotifier;
	final EdgeInsets padding;

	const BlogList({
		super.key,

		required this.scrollController,
		required this.blogs,
		required this.appDirAsync,
		required this.indicatorHeight,

		this.headerNotifier,
		this.padding = EdgeInsets.zero,
	});

	@override
	Widget build(BuildContext context) {
		final leadingWidgetAvatar = CircleAvatar(
			backgroundColor: Palette.blueColor,
			radius: 15,
		);

		if (blogs.isEmpty) {
			return Center(
				child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.article_outlined,
							size: 64,
							color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
						),
						const SizedBox(height: 16),
						Text(
							'No blog posts yet',
							style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
						),
					],
				),
			);
		}

		return ListView.builder(
			controller: scrollController,
			physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
			padding: padding,
			itemCount: blogs.length + 1, // +1 for the indicator slot / header
			itemBuilder: (context, index) {
				if (index == 0) {
					// header slot: use ValueListenable so the parent (HomeView) can inject
					// the current indicator widget without replacing the entire ListView.
					if (headerNotifier != null) {
						return ValueListenableBuilder<Widget?>(
							valueListenable: headerNotifier!,
							builder: (context, header, _) {
								if (header == null) {
									return SizedBox(height: indicatorHeight);
								}
								return header;
							},
						);
					}

					// fallback: simple placeholder
					return SizedBox(height: indicatorHeight);
				}

				final i = index - 1;
				if (i < 0 || i >= blogs.length) {
					return const SizedBox.shrink();
				}

				final blog = blogs[i];
				final images = blog.images ?? <String>[];
				final hasImages = images.isNotEmpty;
				final contentText = blog.content;

				return Container(
					decoration: BoxDecoration(
						color: Palette.backgroundColor.withValues(alpha: 0.5),
						border: Border(
							top: i > 0 ? BorderSide(color: Palette.greyColor.withValues(alpha: 0.2)) : BorderSide.none,
						),
					),
					child: Padding(
						padding: const EdgeInsets.symmetric(vertical: 10),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								BlogListItem(
									content: contentText,
									leading: leadingWidgetAvatar,
									trailing: Text('2h')
								),

								if (hasImages)
									appDirAsync.when(data: (dir) {
										if (blog.images != null) {
											return CarouselSlider(
												items: blog.images!.map((file) {
													final filePath = File(file);
													return Container(
														width: MediaQuery.of(context).size.width,
														margin: const EdgeInsets.symmetric(horizontal: 5),
														child: ClipRRect(
															borderRadius: BorderRadius.circular(8.0),
															child: Image.file(filePath, fit: BoxFit.cover),
														)
													);
												}).toList(),
												options: CarouselOptions(
													height: 400,
													enableInfiniteScroll: false,
													scrollPhysics: const PageScrollPhysics(),
												),
											);
										}
										return const SizedBox.shrink();
									},
									loading: () => const Padding(
									padding: EdgeInsets.symmetric(vertical: 16.0),
										child: Center(child: CircularProgressIndicator()),
									),
									error: (_, _) => const Icon(Icons.error)
								),
							],
						)
					)
				);
			},
		);
	}
}