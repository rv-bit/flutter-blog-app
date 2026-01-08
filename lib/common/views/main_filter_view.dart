
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/common/widgets/blog_widgets/filters/index.dart';

import './date_filter_view.dart';
import './sort_filter_view.dart';

class FilterMainScreen extends StatefulWidget {
	final BlogFilterOptions initialOptions;
	final BlogFilterCallback onApply;

	const FilterMainScreen({
		super.key, 

		required this.initialOptions,
		required this.onApply,
	});

	@override
	State<FilterMainScreen> createState() => FilterMainScreenState();
}

class FilterMainScreenState extends State<FilterMainScreen> {
	late SortBy selectedSortBy;
	late SortOrder selectedSortOrder;
	late DatePosted selectedDatePosted;

	@override
	void initState() {
		super.initState();
		selectedSortBy = widget.initialOptions.sortBy;
		selectedSortOrder = widget.initialOptions.sortOrder;
		selectedDatePosted = widget.initialOptions.datePosted;
	}

	String _getSortLabel() {
		final sortByLabel = selectedSortBy == SortBy.createdAt ? 'Created At' : 'Updated At';
		final orderLabel = selectedSortOrder == SortOrder.asc ? 'Ascending' : 'Descending';
		return '$sortByLabel • $orderLabel';
	}

	String _getDateLabel() {
		switch (selectedDatePosted) {
			case DatePosted.allTime:
				return 'All time';
			case DatePosted.pastHour:
				return 'Past hour';
			case DatePosted.past24Hours:
				return 'Past 24 hours';
			case DatePosted.pastWeek:
				return 'Past week';
			case DatePosted.pastMonth:
				return 'Past month';
			case DatePosted.pastYear:
				return 'Past year';
		}
	}

	void _navigateToSortScreen() async {
		final result = await showCupertinoModalBottomSheet<Map<String, dynamic>>(
			context: context,
			backgroundColor: Colors.transparent,
			useRootNavigator: true,
			builder: (context) => SortFilterScreen(
				initialSortBy: selectedSortBy,
				initialSortOrder: selectedSortOrder,
			),
		);

		if (result != null) {
			setState(() {
				selectedSortBy = result['sortBy'];
				selectedSortOrder = result['sortOrder'];
			});
		}
	}

	void _navigateToDateScreen() async {
		final result = await showCupertinoModalBottomSheet<DatePosted>(
			context: context,
			useRootNavigator: true,
			backgroundColor: Colors.transparent,
			builder: (context) => DateFilterScreen(
				initialDatePosted: selectedDatePosted,
			),
		);

		if (result != null) {
			setState(() {
				selectedDatePosted = result;
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: theme.AppTheme.theme.scaffoldBackgroundColor,
				borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
			),
			child: SafeArea(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						const SizedBox(height: 8),
						Container(
							width: 40,
							height: 4,
							decoration: BoxDecoration(
								color: Colors.grey[300],
								borderRadius: BorderRadius.circular(2),
							),
						),

						Center(
							child: Padding(
								padding: EdgeInsets.all(8),
								child: Text(
									'Filters',
									style: TextStyle(
										fontSize: 15,
										decoration: TextDecoration.none,
										color: Colors.white,
									),
								),
							)
						),
						
						Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

						_buildNavigationTile(
							title: 'Sort',
							subtitle: _getSortLabel(),
							onTap: _navigateToSortScreen,
						),

						Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

						_buildNavigationTile(
							title: 'Date posted',
							subtitle: _getDateLabel(),
							onTap: _navigateToDateScreen,
						),

						Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

						Padding(
							padding: const EdgeInsets.all(16),
							child: GestureDetector(
								onTap: () {
									widget.onApply(BlogFilterOptions(
										sortBy: selectedSortBy,
										sortOrder: selectedSortOrder,
										datePosted: selectedDatePosted,
									));
									Navigator.pop(context);
								},
								child: Container(
									width: double.infinity,
									height: 50,
									decoration: BoxDecoration(
										color: theme.Palette.whiteColor,
										borderRadius: BorderRadius.circular(30),
									),
									child: Center(
										child: Text(
											'Apply',
											style: TextStyle(
												fontSize: 16,
												decoration: TextDecoration.none,
												fontWeight: FontWeight.bold,
												color: theme.Palette.backgroundColor,
											),
										),
									),
								),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildNavigationTile({
		required String title,
		required String subtitle,
		required VoidCallback onTap,
	}) {
		return GestureDetector(
			onTap: onTap,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										title,
										style: TextStyle(
											fontSize: 15,
											decoration: TextDecoration.none,
											fontWeight: FontWeight.w600,
											color: theme.Palette.whiteColor,
										),
									),
									const SizedBox(height: 4),
									Text(
										subtitle,
										style: TextStyle(
											fontSize: 13,
											decoration: TextDecoration.none,
											color: theme.Palette.greyColor.withValues(alpha: 0.7),
										),
									),
								],
							),
						),
						Icon(
							CupertinoIcons.chevron_right,
							color: theme.Palette.whiteColor.withValues(alpha: 0.5),
							size: 20,
						),
					],
				),
			),
		);
	}
}