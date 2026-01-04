import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_blog_app/config/theme/theme_pallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;

import '../../../controllers/search_controller.dart';

class AppBar extends ConsumerStatefulWidget {
    final TextEditingController searchController;
    final common_controllers.InterfaceController interfaceController;
    
    const AppBar({
        super.key,
        required this.searchController,
        required this.interfaceController
    });

    @override
    ConsumerState<AppBar> createState() => _AppBarState();
}

class _AppBarState extends ConsumerState<AppBar> {
    @override
    Widget build(BuildContext context) {
        return AnimatedBuilder(
            animation: widget.interfaceController,
            builder: (context, _) {
                final topInset = MediaQuery.of(context).viewPadding.top;
                final totalHeight = common_controllers.kAppBarHeight + topInset;
                return AnimatedPositioned(
                    top: widget.interfaceController.isHidden ? -totalHeight : 0,
                    left: 0,
                    right: 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    child: ClipRect(
                        child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: theme.Palette.backgroundColor.withValues(alpha: 0.5),
                                    border: Border(
                                        bottom: BorderSide(
                                            color: theme.Palette.greyColor.withValues(alpha: 0.2),
                                        ),
                                    ),
                                ),
                                child: SafeArea(
                                    bottom: false,
                                    child: _buildNormalAppBar(context, ref)
                                ),
                            ),
                        )
                    ),
                );
            },
        );
    }

	Widget _buildNormalAppBar(BuildContext context, WidgetRef ref) {
		return SizedBox(
			height: common_controllers.kAppBarHeight,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				child: Row(
					children: [
						Expanded(
							child: AnimatedAlign(
								duration: const Duration(milliseconds: 50),
								curve: Curves.linear,
								alignment: Alignment.centerLeft,
								child: SizedBox(
									child: ConstrainedBox(
										constraints: BoxConstraints(
											maxWidth: double.infinity,
										),
										child: SizedBox(
											height: 35,
											child: CupertinoTextField(
												controller: widget.searchController,
												maxLines: 1,
												scrollPhysics: const ClampingScrollPhysics(),
												scrollPadding: EdgeInsets.zero,
												crossAxisAlignment: CrossAxisAlignment.center,
												clearButtonMode: OverlayVisibilityMode.editing,
												textAlign: TextAlign.left,
												padding: const EdgeInsets.symmetric(
													horizontal: 12,
													vertical: 8,
												),
												style: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.bold,
													color: Theme.of(context).textTheme.bodyLarge?.color,
												),
												cursorColor: Theme.of(context).colorScheme.primary,
												decoration: BoxDecoration(
													color: Palette.greyColor.withValues(alpha: 0.4),
													borderRadius: BorderRadius.circular(30),
												),
												placeholder: 'Search',
												placeholderStyle: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.bold,
													color: theme.AppTheme.theme.hintColor,
												),
												prefix: Padding(
													padding: const EdgeInsets.only(
														left: 10,
													),
													child: Icon(
														CupertinoIcons.search,
														size: 18,
														color: theme.AppTheme.theme.hintColor,
													)
												),
												onChanged: (value) {
													setState(() {}); // Rebuild to hide/show hint
													ref.read(searchQueryProvider.notifier).setQuery(value);
												},
												onTapOutside: (event) {
													FocusManager.instance.primaryFocus?.unfocus();
												},
											),
										),
									),
								),
							),
						),
						SizedBox(
							child: Padding(
								padding: const EdgeInsets.only(right: 5, left: 15),
								child: GestureDetector(
									onTap: () {},
									child: Icon(
										CupertinoIcons.slider_horizontal_3
									),
								),
							)
						),
					],
				),
			),
		);
	}
}