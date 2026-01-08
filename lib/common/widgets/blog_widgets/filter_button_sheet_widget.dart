import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

import 'package:flutter_blog_app/common/views/main_filter_view.dart';

typedef BlogFilterCallback = void Function(BlogFilterOptions options);

enum SortBy { createdAt, updatedAt }
enum SortOrder { asc, desc }

enum DatePosted {
	allTime,
	pastHour,
	past24Hours,
	pastWeek,
	pastMonth,
	pastYear,
}

class BlogFilterOptions {
	final SortBy sortBy;
	final SortOrder sortOrder;
	final DatePosted datePosted;

	BlogFilterOptions({
		required this.sortBy,
		required this.sortOrder,
		required this.datePosted,
	});

	@override
	String toString() {
		return 'SortBy: $sortBy, SortOrder: $sortOrder, DatePosted: $datePosted';
	}
}

class BlogFilterButton extends StatelessWidget {
	final BlogFilterOptions initialOptions;
	final BlogFilterCallback onApply;

	const BlogFilterButton({
		super.key,
		required this.initialOptions,
		required this.onApply,
	});

	void _showFilterModal(BuildContext context) {
		showCupertinoModalBottomSheet(
			context: context,
			backgroundColor: Colors.transparent,
			useRootNavigator: true,
			builder: (ctx) => FilterMainScreen(
				initialOptions: initialOptions,
				onApply: onApply,
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () => _showFilterModal(context),
			child: const Icon(CupertinoIcons.slider_horizontal_3, color: theme.Palette.whiteColor),
		);
	}
}