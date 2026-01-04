import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/models/index.dart' as models;

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;

import 'package:flutter_blog_app/common/widgets/blog_widgets/action_sheet_widget.dart';

import '../../controllers/home_controller.dart';
import '../blog_widgets/blog_list_content_widget.dart';

class BlogList extends ConsumerWidget {
  	final ScrollController scrollController;
	final ValueListenable<Widget?>? headerNotifier;
	
	// data
	final List<models.BlogPost> blogs;
	
	// styles
	final double indicatorHeight;
	final EdgeInsets padding;

	// selection mode 
	final bool isSelectionMode;
	final Set<String> selectedBlogIds;
	final ValueChanged<String>? onBlogSelectionToggle;

	const BlogList({
		super.key,

		required this.scrollController,
		required this.blogs,
		required this.indicatorHeight,

		this.isSelectionMode = false,
		this.selectedBlogIds = const {},
		this.onBlogSelectionToggle,

		this.headerNotifier,
		this.padding = EdgeInsets.zero,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
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
				final hasImages = blog.images != null && blog.images!.isNotEmpty;

				return _BlogListItem(
					indexItem: i,
					blog: blog,
					hasImages: hasImages,
					isSelectionMode: isSelectionMode,
					isSelected: selectedBlogIds.contains(blog.id),
					onSelectionToggle: () => onBlogSelectionToggle?.call(blog.id),
					onActionPressedWidget: (ctx) => BlogActionSheet.buildPopupMenuButton(
						context: ctx, 
						actions: [
							ActionSheetItem(
								title: 'Edit',
								icon: Icons.edit_outlined,
								onTap: () {
									final router = GoRouter.of(context);
									router.pushNamed('edit', pathParameters: {
										'blogId': blog.id
									});
								},
							),
							ActionSheetItem(
								title: 'Delete',
								icon: Icons.restore_from_trash_sharp,
								isDestructive: true,
								onTap: () {
									BlogActionSheet.showConfirmationDialog(
										context: context,
										title: 'Delete Blog Post',
										text: 'Are you sure you want to delete this blog post? This action cannot be undone.',
										cancelTitle: 'Cancel',
										submitTitle: 'Delete',
										onSubmit: () async {
											await ref.read(homeViewProvider.notifier).deleteBlog(blog.id);
										},
									);
								},
							),
						]
					),
				);
			},
		);
	}
}

class _BlogListItem extends StatefulWidget {
	final int indexItem;

	final models.BlogPost blog;
	final bool hasImages;
	final bool isSelectionMode;
	final bool isSelected;
	final VoidCallback onSelectionToggle;
	final Widget Function(BuildContext context)? onActionPressedWidget;

	const _BlogListItem({
		required this.indexItem,

		required this.blog,
		required this.hasImages,
		required this.isSelectionMode,
		required this.isSelected,
		required this.onSelectionToggle,
		required this.onActionPressedWidget,
	});

	@override
	State<_BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<_BlogListItem> {
	bool _isLongPressed = false;
	bool _longPressCanceled = false;

	void _onItemTap(String blogId) {
		GoRouter.of(context).pushNamed('individual_blog', 
			pathParameters: {
				'blogId': blogId
			}
		);
	}

	@override
	Widget build(BuildContext context) {
		final blog = widget.blog;

		final hasImages = blog.images != null && blog.images!.isNotEmpty;
		final imageData = hasImages ? blog.imageData : null;

		return GestureDetector(
			behavior: HitTestBehavior.opaque,
			onTap: () => _onItemTap(blog.id),
			onLongPressStart: (_) {
				setState(() {
					_isLongPressed = true;
					_longPressCanceled = false;
				});
			},

			onLongPressMoveUpdate: (details) {
				// Cancel if user moves finger vertically (scroll intent)
				if (details.offsetFromOrigin.dy.abs() > 10 || details.offsetFromOrigin.dx.abs() > 10) {
					_longPressCanceled = true;
					setState(() => _isLongPressed = false);
				}
			},

			onLongPressEnd: (_) {
				setState(() => _isLongPressed = false);

				if (!_longPressCanceled) {
					_onItemTap(blog.id);
				}
			},

			onLongPressCancel: () {
				_longPressCanceled = true;
				setState(() => _isLongPressed = false);
			},
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 20),
				curve: Curves.linear,
				decoration: BoxDecoration(
					color: _isLongPressed
						? theme.Palette.greyColor.withValues(alpha: 0.2)
						: theme.Palette.backgroundColor.withValues(alpha: 0.5),
					border: Border(
						top: widget.indexItem > 0 ? BorderSide(color: theme.Palette.greyColor.withValues(alpha: 0.2)) : BorderSide.none,
					),
				),
				child: Column(
					children: [
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 10),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									BlogListContent(
										content: widget.blog.content,
										username: 'username_example',
										time: common_utils.formatPostTime(blog.createdAt),
										avatarWidget: CircleAvatar(
											backgroundColor: theme.Palette.blueColor,
											radius: 15,
										),
										isSelectionMode: widget.isSelectionMode,
										isSelected: widget.isSelected,
										onSelectionToggle: widget.onSelectionToggle,
										onActionPressedWidget: widget.onActionPressedWidget,
									),

									const SizedBox(height: 5),

									if (widget.hasImages)
										CarouselSlider(
											items: imageData!.map((base64String) {
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
										)
								],
							)
						)
					],
				),
			)
		);
	}
}
