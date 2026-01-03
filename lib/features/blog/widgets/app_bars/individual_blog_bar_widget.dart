import 'dart:ui';

import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:flutter_blog_app/models/database/blog_posts.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;

import 'package:flutter_blog_app/common/widgets/blog_widgets/action_sheet_widget.dart';

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';

class AppBar extends ConsumerWidget implements m.PreferredSizeWidget {
	final BlogPost blog;
	final common_controllers.InterfaceController interfaceController;

	const AppBar({
		super.key,

		required this.blog,
		required this.interfaceController
	});

	void onHandleCloseButton(m.BuildContext context) {
		final router = GoRouter.of(context);

		if (router.canPop()) { // handle go back in history, only if there is any history to go back to
			router.pop();
		} else {
			router.go('/'); // Navigate to home if no previous route
		}
	}

	@override
	m.Size get preferredSize => const m.Size.fromHeight(m.kToolbarHeight);

	@override
	m.Widget build(m.BuildContext context, WidgetRef ref) {
		final textStyle = m.DefaultTextStyle.of(context).style;

		return m.AnimatedBuilder(
			animation: interfaceController,
			builder: (context, _) {
				final topInset = m.MediaQuery.of(context).viewPadding.top;
				final totalHeight = common_controllers.kAppBarHeight + topInset;
				
				return m.AnimatedPositioned(
					top: interfaceController.isHidden ? -totalHeight : 0,
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: m.Curves.easeIn,
					child: m.ClipRect(
						child: m.BackdropFilter(
							filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
							child: m.Container(
								decoration: m.BoxDecoration(
									color: theme.Palette.backgroundColor.withValues(alpha: 0.5),
									border: m.Border(
										bottom: m.BorderSide(
											color: theme.Palette.greyColor.withValues(alpha: 0.2),
										),
									),
								),
								child: m.AppBar(
									titleSpacing: 0,
									leadingWidth: 40,
									backgroundColor: theme.Palette.backgroundColor,
									leading: m.IconButton(
										onPressed: () => onHandleCloseButton(context),
										icon: const m.Icon(m.Icons.arrow_back, size: 25),
									),
									title: m.Row(
										crossAxisAlignment: m.CrossAxisAlignment.center,
										mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
										children: [
											m.Align(
												alignment: Alignment.center,
												child: m.Text(
													blog.title,
													style: textStyle.copyWith(fontWeight: m.FontWeight.bold, fontSize: 15),
													maxLines: null,
												),
											),
											m.Container(
												alignment: m.Alignment.centerRight,
												child: m.Opacity(
													opacity: 1.0,
													child: m.Builder(
														builder: (buttonContext) => m.SizedBox(
															width: 36,
															height: 36,
															child: BlogActionSheet.buildPopupMenuButton(
																context: buttonContext,
																actions: [
																	ActionSheetItem(
																		title: 'Edit',
																		icon: m.Icons.edit_outlined,
																		onTap: () {
																			final router = GoRouter.of(context);
																			router.pushNamed('edit', pathParameters: {
																				'blogId': blog.id
																			});
																		},
																	),
																	ActionSheetItem(
																		title: 'Delete',
																		icon: m.Icons.restore_from_trash_sharp,
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

																					if (!context.mounted) return;

																					onHandleCloseButton(context);
																				},
																			);
																		},
																	),
																],
															),
														),
													),
												),
											)
										],
									),
								)
							)
						),
					)
				);
			},
		);
	}
}