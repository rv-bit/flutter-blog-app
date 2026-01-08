
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

import '../widgets/blog_widgets/filter_button_sheet_widget.dart';

class DateFilterScreen extends StatefulWidget {
	final DatePosted initialDatePosted;

	const DateFilterScreen({
		super.key, 

		required this.initialDatePosted,
	});

	@override
	State<DateFilterScreen> createState() => DateFilterScreenState();
}

class DateFilterScreenState extends State<DateFilterScreen> {
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