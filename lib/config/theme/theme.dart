import 'package:flutter/material.dart';

import './theme_pallet.dart';

class AppTheme {
	static ThemeData theme = ThemeData.dark().copyWith(
		scaffoldBackgroundColor: Palette.backgroundColor,
		floatingActionButtonTheme: FloatingActionButtonThemeData(
			backgroundColor: Palette.blueColor,
		),
		textSelectionTheme: TextSelectionThemeData(
			cursorColor: Palette.whiteColor,
			selectionColor: Palette.searchBarColor,
			selectionHandleColor: Palette.backgroundColor,
		),
	);
}