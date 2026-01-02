import 'dart:convert';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/config/navigation_config.dart';
import 'package:flutter_blog_app/config/theme/index.dart' as theme;

import 'package:flutter_blog_app/common/providers/index.dart' as common_providers;
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

import 'package:flutter_blog_app/models/blog_posts.dart';

import '../widgets/blog_widgets/blog_content_widget.dart';
import '../widgets/app_bars/individual_blog_bar_widget.dart';

import '../controllers/individual_blog_controller.dart';

final interfaceController = common_controllers.InterfaceController();

class IndividualBlogView extends ConsumerStatefulWidget {
	final String blogId;

	const IndividualBlogView({
		super.key, 
		required this.blogId
	});

  	@override ConsumerState<ConsumerStatefulWidget> createState() => _IndividualBlogViewState();
}

class _IndividualBlogViewState extends ConsumerState<IndividualBlogView> {
	bool _initialized = false;
	final ScrollController _scrollController = ScrollController();

	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		_scrollController.dispose();
		super.dispose();
	}

	void onHandleCloseButton() {
		final router = GoRouter.of(context);

		if (router.canPop()) { // handle go back in history, only if there is any history to go back to
			router.pop();
		} else {
			router.go('/'); // Navigate to home if no previous route
		}
	}

	@override
	Widget build(BuildContext context) {
		final activeTabIndex = ref.watch(common_controllers.navigationControllerProvider);
		final appDirAsync = ref.watch(common_providers.appDirectoryProvider);

		ref.listen<AsyncValue<BlogPost?>>(
			individualBlogProvider(widget.blogId),
			(previous, next) {
				next.whenOrNull(
					data: (blog) {
						if (blog == null || _initialized) return;

						_initialized = true;
					},
				);
			},
		);

		final blogAsync = ref.watch(individualBlogProvider(widget.blogId));

		return Scaffold(
			body: SafeArea(
				child: blogAsync.when(
					data: (blog) {
						if (blog == null) {
							return const Center(child: Text('Blog not found'));
						}

						return Stack(
							children: [
								NotificationListener<ScrollNotification>(
									onNotification: (notification) {
										if (notification.metrics.axis == Axis.vertical && notification.depth == 0) {
											interfaceController.onScroll(notification);
										}
										return false;
									},
									child: SingleChildScrollView(
										controller: _scrollController,
										child: _blogContent(context, blog, appDirAsync)
									),
								),
								
								AppBar(
									blog: blog,
									interfaceController: interfaceController,
								),
							],
						);
					},
					loading: () => const Padding(
						padding: EdgeInsets.only(top: 60.0),
						child: Center(
							child: CircularProgressIndicator(),
						),
					),
					error: (error, stack) => Padding(
						padding: const EdgeInsets.only(top: 60.0),
						child: Center(
							child: Text('Error: $error'),
						),
					),
				),
			),
			bottomNavigationBar: common_widgets.StaticBottomBar(
				currentIndex: activeTabIndex,
				onTap: (index) {
					ref.read(common_controllers.navigationControllerProvider.notifier).setActiveTab(index);
					context.go(ShellRoutes.fromIndex(index).path);
				},
			),
		);
	}

	Widget _blogContent(BuildContext context, BlogPost blog, AsyncValue appDirAsync) {
		final textStyle = theme.AppTheme.theme.textTheme.bodyMedium!;

		final hasImages = blog.images != null && blog.images!.isNotEmpty;
		final imageData = hasImages ? blog.imageData : null;
		final imageCount = blog.imageData?.length ?? 0;

		final isEdited = blog.updatedAt != null && blog.updatedAt!.isNotEmpty;
		final time = isEdited ? common_utils.formatDate(blog.updatedAt!, showBoth: true) : common_utils.formatDate(blog.createdAt, showBoth: true);

		return Container(
			decoration: BoxDecoration(
				border: Border(
					bottom: BorderSide(color: theme.Palette.greyColor.withValues(alpha: 0.2)),
				),
			),
			padding: const EdgeInsets.only(bottom: 20),
			child: Padding(
				padding: const EdgeInsets.only(
					left: 15,
					right: 10,
					top: 60,
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						BlogListContent(
							content: blog.content,
							username: 'username_example',
							avatarWidget: CircleAvatar(
								backgroundColor: theme.Palette.blueColor,
								radius: 15,
							),
							appDirAsync: appDirAsync,
						),

						if (hasImages) ...[
							Padding(
								padding: const EdgeInsets.only(top: 10),
								child: appDirAsync.when(
									data: (_) {
										if (imageCount == 1) {
											return _singleImage(context, imageData!.first);
										} else {
											return _imageCarousel(context, imageData!);
										}
									},
									loading: () => const Padding(
										padding: EdgeInsets.symmetric(vertical: 16),
										child: Center(child: CircularProgressIndicator()),
									),
									error: (_, _) => const Icon(Icons.error),
								),
							)
						],

						Padding(
							padding: const EdgeInsets.only(top: 10),
							child: Text(
								time,
								style: textStyle.copyWith(
									fontSize: 12,
									color: Colors.grey[600],
									fontWeight: FontWeight.bold,
									decoration: TextDecoration.none,
								),
							),
						)
					],
				),
				),
		);
	}

	Widget _singleImage(BuildContext context, String base64) {
		return ClipRRect(
			borderRadius: BorderRadius.circular(12),
			child: Image.memory(
				base64Decode(base64),
				width: double.infinity,
				height: 300,
				fit: BoxFit.cover,
				gaplessPlayback: true,
			),
		);
	}

	Widget _imageCarousel(BuildContext context, List<String> images) {
		final width = MediaQuery.of(context).size.width;

		return CarouselSlider(
			items: images.map((base64) {
				return Container(
					margin: const EdgeInsets.symmetric(horizontal: 5),
					child: ClipRRect(
						borderRadius: BorderRadius.circular(8.0),
						child: AspectRatio(
							aspectRatio: 1,
							child: Image.memory(
								base64Decode(base64),
								fit: BoxFit.cover,
								gaplessPlayback: true,
							),
						),
					),
				);
			}).toList(),
			options: CarouselOptions(
				height: width * 0.8,
				viewportFraction: 0.8,
				enableInfiniteScroll: false,
				padEnds: false,
			),
		);
	}

}