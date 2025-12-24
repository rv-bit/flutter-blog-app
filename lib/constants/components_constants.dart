import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_app/common/controllers/ui_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

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
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return ClipRect(
			child: BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
				child: Padding(
					padding: EdgeInsets.only(bottom: bottomInset / 2),
					child: MediaQuery.removePadding(
						context: context,
						removeBottom: true,
						child: CupertinoTabBar(
							currentIndex: currentIndex,
							onTap: onTap,
							height: kBottomBarHeight + bottomInset / 2,
							backgroundColor: Palette.backgroundColor.withValues(alpha: 0.5),
							border: Border(
								top: BorderSide(color: Palette.greyColor.withValues(alpha: 0.2)),
							),
							items: [
								BottomNavigationBarItem(
									icon: SvgPicture.asset(
										currentIndex == 0
											? AssetsConstants.homeFilledIcon
											: AssetsConstants.homeOutlinedIcon,
										colorFilter: ColorFilter.mode(
											currentIndex == 0
												? Palette.whiteColor
												: const Color.fromARGB(255, 114, 68, 68),
											BlendMode.srcIn,
										),
										height: 20,
									),
								),
								BottomNavigationBarItem(
									icon: SvgPicture.asset(
										AssetsConstants.searchIcon,
										colorFilter: ColorFilter.mode(
											currentIndex == 1
												? Palette.whiteColor
												: Palette.greyColor,
											BlendMode.srcIn,
										),
										height: 20,
									),
								),
							],
						),
					),
				),
			),
		);
	}
}


class StaticFAB extends StatelessWidget {
	final VoidCallback onPressed;
	final Widget icon;

	const StaticFAB({
		super.key,
		required this.onPressed,
		required this.icon,
	});

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return SafeArea(
			bottom: true,
			child: Container(
				margin: EdgeInsets.only(bottom: bottomInset / 2),
				child: FloatingActionButton(
					shape: RoundedSuperellipseBorder(
						borderRadius: BorderRadius.circular(30.0),
					),
					onPressed: onPressed,
					elevation: 0,
					child: icon,
				),
			),
		);
	}
}