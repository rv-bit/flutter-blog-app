import 'package:flutter/material.dart';

import './theme_pallet.dart';

class AppTheme {
	static ThemeData theme = ThemeData.dark().copyWith(
		colorScheme: ColorScheme.fromSeed(
			brightness: Brightness.dark,
			seedColor: Palette.whiteColor,

			primary: Palette.whiteColor, 
			onPrimary: Palette.whiteColor, 
			
			secondary: Palette.greyColor, 
			onSecondary: Palette.greyColor
		),
		scaffoldBackgroundColor: Palette.backgroundColor,
		floatingActionButtonTheme: FloatingActionButtonThemeData(
			backgroundColor: Palette.blueColor,
		),
		textSelectionTheme: TextSelectionThemeData(
			cursorColor: Palette.whiteColor,
			selectionColor: Palette.searchBarColor,
			selectionHandleColor: Palette.backgroundColor,
		),
		hintColor: Palette.greyColor.withValues(alpha: 0.8)
	);
}