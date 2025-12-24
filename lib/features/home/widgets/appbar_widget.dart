import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';

class GlassAppBar extends StatelessWidget {
	const GlassAppBar({super.key});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: scrollUIController,
			builder: (context, _) {
				final height = lerpDouble(
					kAppBarHeight,
					kAppBarLiftThreshold,
					scrollUIController.isHidden ? 1 : 0,
				)!;

				return ClipRect(
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
								child: AnimatedContainer(
									height: height,
									duration: const Duration(milliseconds: 200),
									curve: Curves.easeIn,
									child: Center(
										child: scrollUIController.isHidden ? 
										const SizedBox.shrink() : SvgPicture.asset(
											AssetsConstants.logoIcon,
											height: 25,
										),
									),
								),
							),
						),
					),
				);
			},
		);
	}
}
