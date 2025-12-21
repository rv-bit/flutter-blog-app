import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

class ComponentsConstants {
	static AppBar appBar() {
		return AppBar(
			title: SvgPicture.asset(
				AssetsConstants.searchIcon,
				colorFilter: ColorFilter.mode(Palette.whiteColor, BlendMode.srcIn),
				height: 30,
			),
			centerTitle: true,
		);	
	}
}