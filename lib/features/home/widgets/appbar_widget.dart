import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';

class CustomAppBar extends StatelessWidget {
	const CustomAppBar({super.key});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: scrollUIController,
			builder: (context, _) {
				final topInset = MediaQuery.of(context).viewPadding.top;
				final totalHeight = kAppBarHeight + topInset;
				
				return AnimatedPositioned(
					top: scrollUIController.isHidden ? -totalHeight : 0,
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: ClipRect(
						child: BackdropFilter(
							filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
							child: Container(
								decoration: BoxDecoration(
									color: Palette.backgroundColor.withValues(alpha: 0.5),
									border: Border(
										bottom: BorderSide(
											color: Palette.greyColor.withValues(alpha: 0.2),
										),
									),
								),
								child: SafeArea(
									bottom: false,
									child: SizedBox(
										height: kAppBarHeight,
										child: Center(
											child: SvgPicture.asset(
												AssetsConstants.logoIcon,
												height: 25,
											),
										),
									),
								),
							),
						)
					),
				);
			},
		);
	}
}
