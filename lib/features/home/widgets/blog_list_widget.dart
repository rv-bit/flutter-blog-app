import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/config/theme.dart';
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;

import 'package:flutter_blog_app/models/blog_posts.dart';

import 'package:flutter_blog_app/features/home/widgets/blog_list_text_widget.dart';
import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';

class BlogList extends ConsumerWidget {
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

	void _showActionSheet(BuildContext context, WidgetRef ref, BlogPost blog) {
		showMaterialModalBottomSheet(
			context: context,
			useRootNavigator: true,
			backgroundColor: Colors.transparent,
			builder: (sheetContext) => Container(
				decoration: BoxDecoration(
					color: AppTheme.theme.scaffoldBackgroundColor,
					borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
				),
				child: SafeArea(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const SizedBox(height: 8),
							Container(
								width: 40,
								height: 4,
								decoration: BoxDecoration(
									color: Colors.grey[300],
									borderRadius: BorderRadius.circular(2),
								),
							),
							const SizedBox(height: 16),
							ListTile(
								leading: const Icon(Icons.edit_outlined),
								title: const Text('Edit'),
								onTap: () {
									final router = GoRouter.of(context);

									Navigator.pop(sheetContext);

									router.pushNamed('edit', pathParameters: {
										'blogId': blog.id
									});
								},
							),
							const SizedBox(height: 16),
							ListTile(
								leading: const Icon(
									Icons.restore_from_trash_sharp,
									color: Palette.redColor,
								),
								title: const Text(
									'Delete', 
									style: TextStyle(
										fontSize: 14,
										color: Palette.redColor,
										fontWeight: FontWeight.bold,
									),
								),
								onTap: () {
									Navigator.pop(sheetContext);
									_showDeleteConfirmation(context, ref, blog);
								},
							),
							const SizedBox(height: 16),
						],
					),
				),
			),
		);
	}

	void _showDeleteConfirmation(BuildContext context, WidgetRef ref, BlogPost blog) {
		showDialog(
			context: context,
			builder: (dialogContext) => AlertDialog(
				title: const Text('Delete Post?'),
				content: const Text('Are you sure you want to delete this blog post? This action cannot be undone.'),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(dialogContext),
						child: const Text('Cancel'),
					),
					TextButton(
						onPressed: () async {
							Navigator.pop(dialogContext);
							late BuildContext loadingDialogContext;

							// Show loading indicator
							showDialog(
								context: context,
								barrierDismissible: false,
								builder: (ctx) {
									loadingDialogContext = ctx;

									return const Center(
										child: CircularProgressIndicator(),
									);
								}
							);
							
							// Delete the blog
							await ref.read(homeViewProvider.notifier).deleteBlog(blog.id);
							
							// Close loading indicator
							if (loadingDialogContext.mounted) {
								Navigator.pop(loadingDialogContext);
							}
							
							debugPrint('Deleted blog: ${blog.id}');
						},
						style: TextButton.styleFrom(
							foregroundColor: Palette.redColor,
						),
						child: const Text('Delete'),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		if (blogs.isEmpty) {
			return Center(
				child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.article_outlined,
							size: 64,
							color: AppTheme.theme.colorScheme.onSurface.withAlpha(80),
						),
						const SizedBox(height: 16),
						Text(
							'No blog posts yet',
							style: AppTheme.theme.textTheme.titleMedium?.copyWith(color: AppTheme.theme.colorScheme.onSurface.withAlpha(120)),
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

					return SizedBox(height: indicatorHeight);
				}

				final i = index - 1;
				if (i < 0 || i >= blogs.length) {
					return const SizedBox.shrink();
				}

				final blog = blogs[i];
				final images = blog.images;
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
									username: 'username_example',
									time: common_utils.formatPostTime(blog.createdAt),
									avatarWidget: CircleAvatar(
										backgroundColor: Palette.blueColor,
										radius: 15,
									),
									onActionPressed: (ctx) => _showActionSheet(ctx, ref, blog),
								),

								const SizedBox(height: 5),

								if (hasImages)
									appDirAsync.when(data: (dir) {
										return CarouselSlider(
											items: blog.images.map((imagePath) {
												return Container(
													width: MediaQuery.of(context).size.width,
													margin: const EdgeInsets.symmetric(horizontal: 5),
													child: ClipRRect(
														borderRadius: BorderRadius.circular(8.0),
														child: Image.memory(base64Decode(imagePath), fit: BoxFit.cover),
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
						)
					)
				);
			},
		);
	}
}