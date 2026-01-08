
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_app/config/theme/index.dart' as theme;

import 'package:flutter_blog_app/common/widgets/blog_widgets/filters/index.dart';

class SortFilterScreen extends StatefulWidget {
	final SortBy initialSortBy;
	final SortOrder initialSortOrder;

	const SortFilterScreen({
		super.key, 
		required this.initialSortBy,
		required this.initialSortOrder,
	});

	@override
	State<SortFilterScreen> createState() => SortFilterScreenState();
}

class SortFilterScreenState extends State<SortFilterScreen> {
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
			color: theme.AppTheme.theme.scaffoldBackgroundColor,
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

							buildSectionTitle('Sort by'),
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

							buildSectionTitle('Sort order'),
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
}