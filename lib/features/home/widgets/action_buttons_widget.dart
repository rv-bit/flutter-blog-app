
import 'package:go_router/go_router.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;
import 'package:flutter_blog_app/common/widgets/action_buttons_widget.dart' as common_widgets;

class AnimatedFAB extends StatelessWidget {
	const AnimatedFAB({super.key});

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return AnimatedBuilder(
			animation: common_controllers.globalInterfaceController,
			builder: (_, _) {
				return AnimatedPositioned(
					right: 15,
					bottom: common_controllers.globalInterfaceController.isHidden ? common_controllers.kFabSize / 5 + bottomInset : common_controllers.kBottomBarHeight + common_controllers.kFabBasePadding + bottomInset,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: common_widgets.StaticFAB(
						onPressed: () => context.push('/create'),
						icon: SvgPicture.asset(
							AssetsConstants.blogInsert,
							colorFilter: ColorFilter.mode(theme.Palette.whiteColor, BlendMode.srcIn),
							height: 24,
						),
					),
				);
			},
		);
	}
}
