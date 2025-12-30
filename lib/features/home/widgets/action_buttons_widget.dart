
import 'package:go_router/go_router.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart' as controllers;
import 'package:flutter_blog_app/common/widgets/action_buttons_widget.dart' as widgets;

class AnimatedFAB extends StatelessWidget {
	final int currentIndex;

	const AnimatedFAB({
		super.key,
		required this.currentIndex,
	});

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return AnimatedBuilder(
			animation: controllers.scrollUIController,
			builder: (_, _) {
				return AnimatedPositioned(
					right: 15,
					bottom: controllers.scrollUIController.isHidden ? controllers.kFabSize / 5 + bottomInset : controllers.kBottomBarHeight + controllers.kFabBasePadding + bottomInset,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: widgets.StaticFAB(
						onPressed: () => context.push('/create'),
						icon: SvgPicture.asset(
							AssetsConstants.blogInsert,
							colorFilter: ColorFilter.mode(Palette.whiteColor, BlendMode.srcIn),
							height: 24,
						),
					),
				);
			},
		);
	}
}
