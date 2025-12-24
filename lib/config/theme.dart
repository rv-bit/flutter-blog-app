import 'package:flutter/material.dart';
import 'package:flutter_blog_app/config/theme_pallet.dart';

class AppTheme {
	static ThemeData theme = ThemeData.dark().copyWith(
		scaffoldBackgroundColor: Palette.backgroundColor,
		floatingActionButtonTheme: FloatingActionButtonThemeData(
			backgroundColor: Palette.blueColor,
		),
	);
}