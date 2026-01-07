import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

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
			builder: (ctx) => _FilterMainScreen(
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

class _FilterMainScreen extends StatefulWidget {
	final BlogFilterOptions initialOptions;
	final BlogFilterCallback onApply;

	const _FilterMainScreen({
		required this.initialOptions,
		required this.onApply,
	});

	@override
	State<_FilterMainScreen> createState() => _FilterMainScreenState();
}

class _FilterMainScreenState extends State<_FilterMainScreen> {
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
			builder: (context) => _SortFilterScreen(
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
			builder: (context) => _DateFilterScreen(
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
						const Center(
							child: Padding(
								padding: EdgeInsets.all(4),
								child: Text(
									'Filters',
									style: TextStyle(
										fontSize: 20,
										fontWeight: FontWeight.bold,
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
							child: CupertinoButton.filled(
								onPressed: () {
									widget.onApply(BlogFilterOptions(
										sortBy: selectedSortBy,
										sortOrder: selectedSortOrder,
										datePosted: selectedDatePosted,
									));
									Navigator.pop(context);
								},
								color: theme.Palette.greyColor.withValues(alpha: 0.6),
								child: const Text(
									'Apply', 
									style: TextStyle(
										fontWeight: FontWeight.bold
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
										style: const TextStyle(
											color: theme.Palette.whiteColor,
											fontSize: 16,
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 4),
									Text(
										subtitle,
										style: TextStyle(
											color: theme.Palette.whiteColor.withValues(alpha: 0.7),
											fontSize: 13,
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

class _SortFilterScreen extends StatefulWidget {
	final SortBy initialSortBy;
	final SortOrder initialSortOrder;

	const _SortFilterScreen({
		required this.initialSortBy,
		required this.initialSortOrder,
	});

	@override
	State<_SortFilterScreen> createState() => _SortFilterScreenState();
}

class _SortFilterScreenState extends State<_SortFilterScreen> {
	late SortBy selectedSortBy;
	late SortOrder selectedSortOrder;

	@override
	void initState() {
		super.initState();
		selectedSortBy = widget.initialSortBy;
		selectedSortOrder = widget.initialSortOrder;
	}

	void _handleSortByChange(SortBy? value) {
		if (value != null) {
			setState(() {
				selectedSortBy = value;
			});
			// Auto-dismiss after selection
			Future.delayed(const Duration(milliseconds: 200), () {
				if (mounted) {
					Navigator.pop(context, {
						'sortBy': selectedSortBy,
						'sortOrder': selectedSortOrder,
					});
				}
			});
		}
	}

	void _handleSortOrderChange(SortOrder? value) {
		if (value != null) {
			setState(() {
				selectedSortOrder = value;
			});
			// Auto-dismiss after selection
			Future.delayed(const Duration(milliseconds: 200), () {
				if (mounted) {
					Navigator.pop(context, {
						'sortBy': selectedSortBy,
						'sortOrder': selectedSortOrder,
					});
				}
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			color: Colors.transparent,
			child: Container(
				decoration: BoxDecoration(
					color: theme.AppTheme.theme.scaffoldBackgroundColor,
					borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
				),
				child: SafeArea(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							// Header with back button
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
								child: Row(
									children: [
										CupertinoButton(
											padding: EdgeInsets.zero,
											onPressed: () => Navigator.pop(context),
											child: const Icon(
												CupertinoIcons.back,
												color: theme.Palette.whiteColor,
											),
										),
										const Expanded(
											child: Center(
												child: Text(
													'Sort',
													style: TextStyle(
														fontSize: 20,
														fontWeight: FontWeight.bold,
														color: Colors.white,
													),
												),
											),
										),
										const SizedBox(width: 44), // Balance the back button
									],
								),
							),

							Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

							_buildSectionTitle('Sort by'),
							RadioGroup<SortBy>(
								groupValue: selectedSortBy,
								onChanged: _handleSortByChange,
								child: Column(
									children: [
										ListTile(
											title: const Text(
												'Created At',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<SortBy>(
												value: SortBy.createdAt,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Updated At',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<SortBy>(
												value: SortBy.updatedAt,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
									],
								),
							),

							Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

							_buildSectionTitle('Sort order'),
							RadioGroup<SortOrder>(
								groupValue: selectedSortOrder,
								onChanged: _handleSortOrderChange,
								child: Column(
									children: [
										ListTile(
											title: const Text(
												'Ascending',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<SortOrder>(
												value: SortOrder.asc,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Descending',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<SortOrder>(
												value: SortOrder.desc,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
									],
								),
							),
							const SizedBox(height: 16),
						],
					),
				),
			),
		);
	}

	Widget _buildSectionTitle(String title) {
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
}

class _DateFilterScreen extends StatefulWidget {
	final DatePosted initialDatePosted;

	const _DateFilterScreen({
		required this.initialDatePosted,
	});

	@override
	State<_DateFilterScreen> createState() => _DateFilterScreenState();
}

class _DateFilterScreenState extends State<_DateFilterScreen> {
	late DatePosted selectedDatePosted;

	@override
	void initState() {
		super.initState();
		selectedDatePosted = widget.initialDatePosted;
	}

	void _handleDateChange(DatePosted? value) {
		if (value != null) {
			setState(() {
				selectedDatePosted = value;
			});
			// Auto-dismiss after selection
			Future.delayed(const Duration(milliseconds: 200), () {
				if (mounted) {
					Navigator.pop(context, selectedDatePosted);
				}
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Material(
			color: Colors.transparent,
			child: Container(
				decoration: BoxDecoration(
					color: theme.AppTheme.theme.scaffoldBackgroundColor,
					borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
				),
				child: SafeArea(
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							// Header with back button
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
								child: Row(
									children: [
										CupertinoButton(
											padding: EdgeInsets.zero,
											onPressed: () => Navigator.pop(context),
											child: const Icon(
												CupertinoIcons.back,
												color: theme.Palette.whiteColor,
											),
										),
										const Expanded(
											child: Center(
												child: Text(
													'Date posted',
													style: TextStyle(
														fontSize: 20,
														fontWeight: FontWeight.bold,
														color: Colors.white,
													),
												),
											),
										),
										const SizedBox(width: 44), // Balance the back button
									],
								),
							),

							Divider(height: 1, color: theme.Palette.greyColor.withValues(alpha: 0.5)),

							RadioGroup<DatePosted>(
								groupValue: selectedDatePosted,
								onChanged: _handleDateChange,
								child: Column(
									children: [
										ListTile(
											title: const Text(
												'All time',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.allTime,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Past hour',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.pastHour,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Past 24 hours',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.past24Hours,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Past week',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.pastWeek,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Past month',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.pastMonth,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
										ListTile(
											title: const Text(
												'Past year',
												style: TextStyle(color: theme.Palette.whiteColor, fontSize: 15),
											),
											leading: Radio<DatePosted>(
												value: DatePosted.pastYear,
												fillColor: WidgetStateProperty.resolveWith((states) {
													if (states.contains(WidgetState.selected)) {
														return theme.Palette.blueColor;
													}
													return theme.Palette.whiteColor.withValues(alpha: 0.5);
												}),
											),
											contentPadding: const EdgeInsets.symmetric(horizontal: 16),
										),
									],
								),
							),
							const SizedBox(height: 16),
						],
					),
				),
			),
		);
	}
}