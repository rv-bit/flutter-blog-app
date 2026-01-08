import 'package:flutter/widgets.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

Widget buildSectionTitle(String title) {
	return Padding(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
		child: Align(
			alignment: Alignment.centerLeft,
			child: Text(
				title,
				style: const TextStyle(
					color: theme.Palette.whiteColor,
					fontSize: 14,
					fontWeight: FontWeight.bold,
				),
			),
		),
	);
}