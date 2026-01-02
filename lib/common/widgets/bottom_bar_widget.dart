import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/config/navigation_config.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';

class StaticBottomBar extends StatelessWidget {
	final int currentIndex;
	final void Function(int) onTap;

	const StaticBottomBar({
		super.key,
		required this.currentIndex,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return ClipRect(
			child: BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
				child: Container(
					decoration: BoxDecoration(
						color: theme.Palette.backgroundColor.withValues(alpha: 0.5),
						border: Border(
							top: BorderSide(color: theme.Palette.greyColor.withValues(alpha: 0.2)),
						),
					),
					child: SafeArea(
						top: false,
						child: SizedBox(
							height: kBottomBarHeight,
							child: CupertinoTabBar(
								currentIndex: currentIndex,
								onTap: onTap,
								height: kBottomBarHeight,
								backgroundColor: Colors.transparent,
								border: const Border(),
								items: ShellRoutes.values.map((tab) {
									final isActive = currentIndex == tab.index;

									return BottomNavigationBarItem(
										icon: SvgPicture.asset(
											isActive ? tab.activeIcon : tab.inactiveIcon,
											colorFilter: ColorFilter.mode(
												isActive ? theme.Palette.whiteColor : theme.Palette.greyColor,
												BlendMode.srcIn,
											),
											height: 20,
										),
									);
								}).toList(),
							),
						),
					),
				),
			),
		);
	}
}