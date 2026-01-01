import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/features/blog/widgets/character_indicator_widget.dart';

const int maxCharacters = 100;

class BottomBarActions extends StatelessWidget {
	final VoidCallback onPickImages;
	final VoidCallback onPickImageFromCamera;

	final int currentCharCount;

  	const BottomBarActions({
		super.key,

		required this.onPickImages,
		required this.onPickImageFromCamera,
		required this.currentCharCount,
	});

	@override
	Widget build(BuildContext context) {
		return Transform.translate(
			offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
			child: Container(
				padding: const EdgeInsets.only(bottom: 10),
				decoration: BoxDecoration(
					border: Border(
						top: BorderSide(color: Palette.greyColor.withValues(alpha: 0.5))
					),
					color: Palette.backgroundColor
				),
				child: SafeArea(
					top: false,
					child: Row(
						children: [
							Padding(
								padding: const EdgeInsets.all(8.0).copyWith(
									left: 15,
									right: 15,
								),
								child: GestureDetector(
									onTap: onPickImages,
									child: SvgPicture.asset(
										AssetsConstants.addImageIcon,
										colorFilter: ColorFilter.mode(
											Palette.blueColor,
											BlendMode.srcIn
										),
										height: 24,		
									),
								),
							),
							Padding(
								padding: const EdgeInsets.all(8.0).copyWith(
									left: 0,
									right: 15,
								),
								child: GestureDetector(
									onTap: onPickImageFromCamera,
									child: SvgPicture.asset(
										AssetsConstants.camera,
										colorFilter: ColorFilter.mode(
											Palette.blueColor,
											BlendMode.srcIn
										),
										height: 20,	
									),
								),
							),
							
							const Spacer(),
							Padding(
								padding: const EdgeInsets.only(right: 15, top: 5),
								child: CharacterLimitIndicator(
									currentLength: currentCharCount,
									maxLength: maxCharacters,
									size: 25,
								),
							),
						],
					),
				),
			),
		);
	}
}