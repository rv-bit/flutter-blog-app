import 'package:flutter/material.dart';
import 'package:flutter_blog_app/config/theme_pallet.dart';

class AppTheme {
	static ThemeData theme = ThemeData.dark().copyWith(
		scaffoldBackgroundColor: Palette.backgroundColor,
		appBarTheme: AppBarTheme(
			backgroundColor: Palette.backgroundColor,
			elevation: 0,
		),
		floatingActionButtonTheme: FloatingActionButtonThemeData(
			backgroundColor: Palette.blueColor,
		),
	);
}