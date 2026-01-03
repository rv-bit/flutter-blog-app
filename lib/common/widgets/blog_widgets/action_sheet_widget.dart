import 'dart:io';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;


// Helper to convert Material Icons to SF Symbol names (basic mapping)
String _getSymbolName(IconData icon) {
	// Map common Material Icons to SF Symbols
	if (icon == Icons.edit || icon == Icons.edit_outlined) {
		return 'pencil';
	} else if (icon == Icons.delete || icon == Icons.delete_outline) {
		return 'trash';
	} else if (icon == Icons.restore_from_trash || icon == Icons.restore_from_trash_sharp) {
		return 'trash';
	} else if (icon == Icons.share || icon == Icons.share_outlined) {
		return 'square.and.arrow.up';
	} else if (icon == Icons.more_horiz || icon == Icons.more_vert) {
		return 'ellipsis';
	}

	// Default fallback
	return 'ellipsis';
}

class ActionSheetItem {
	final VoidCallback onTap;
	
	final String title;
	final IconData? icon;

	final Color? textColor;
	final Color? iconColor;
	
	final bool isDestructive;

	const ActionSheetItem({
		required this.onTap,

		required this.title,
		this.textColor,
		this.icon,
		this.iconColor,
		this.isDestructive = false,
	});
}

class BlogActionSheet {
	static Widget buildPopupMenuButton({
		required BuildContext context,
		required List<ActionSheetItem> actions,
		Color? iconColor = theme.Palette.whiteColor,
		IconData? buttonIcon,
		double size = 36,
		CNButtonStyle? buttonStyle,
	}) {
		if (Platform.isIOS) {
			try {
				final menuItems = <CNPopupMenuEntry>[];
				
				for (final action in actions) {
					if (action.isDestructive && menuItems.isNotEmpty) {
						// add divider before destructive actions
						menuItems.add(const CNPopupMenuDivider());
					}
					
					final itemIconColor = action.isDestructive 
						? CupertinoColors.systemRed 
						: action.iconColor;

					menuItems.add(
						CNPopupMenuItem(
							label: action.title,
							icon: action.icon != null 
								? CNSymbol(
									_getSymbolName(action.icon!),
									size: 18,
									color: itemIconColor,
								)
							: null,
							customIcon: action.icon,
							iconColor: itemIconColor,
							enabled: true,
						),
					);
				}

				return CNPopupMenuButton.icon(
					buttonIcon: CNSymbol(
						_getSymbolName(buttonIcon ?? Icons.more_horiz),
						size: 20,
						color: iconColor 
					),
					buttonCustomIcon: buttonIcon ?? Icons.more_horiz,
					size: size,
					items: menuItems,
					onSelected: (index) {
						int actionIndex = 0;
						int menuIndex = 0;
						
						for (int i = 0; i < menuItems.length; i++) {
							if (menuItems[i] is CNPopupMenuItem) {
								if (menuIndex == index) {
									actions[actionIndex].onTap();
									break;
								}
								actionIndex++;
								menuIndex++;
							}
						}
					},
					buttonStyle: buttonStyle ?? CNButtonStyle.plain,
				);
			} catch (e) {
				return SizedBox(
					width: size,
					height: size,
					child: IconButton(
						padding: EdgeInsets.zero,
						icon: Icon(
							buttonIcon ?? Icons.more_horiz,
							size: 20,
							color: Colors.grey[600],
						),
						onPressed: () => _showMaterial(context, actions),
					),
				);
			}
		} else {
			return SizedBox(
				width: size,
				height: size,
				child: IconButton(
					padding: EdgeInsets.zero,
					icon: Icon(
						buttonIcon ?? Icons.more_horiz,
						size: 20,
						color: Colors.grey[600],
					),
					onPressed: () => _showMaterial(context, actions),
				),
			);
		}
	}

	static void showActionSheet({
		required BuildContext context,
		required List<ActionSheetItem> actions,
	}) {
		if (Platform.isIOS) {
			_showCupertino(context, actions);
		} else {
			_showMaterial(context, actions);
		}
	}

	static void showConfirmationDialog({
		required BuildContext context,
		required String cancelTitle,
		required String submitTitle,
		required String title,
		required String text,
		required Future<void> Function() onSubmit,
	}) {
		if (Platform.isIOS) {
			_showCupertinoConfirmation(
				context,
				cancelTitle,
				submitTitle,
				title,
				text,
				onSubmit,
			);
		} else {
			_showMaterialConfirmation(
				context,
				cancelTitle,
				submitTitle,
				title,
				text,
				onSubmit,
			);
		}
	}

	static void _showMaterial(
		BuildContext context,
		List<ActionSheetItem> actions,
	) {
		showMaterialModalBottomSheet(
			context: context,
			useRootNavigator: true,
			backgroundColor: Colors.transparent,
			builder: (sheetContext) => Container(
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
							const SizedBox(height: 16),
							...actions.map((action) => Padding(
									padding: const EdgeInsets.only(bottom: 16),
									child: _buildMaterialTile(context, sheetContext, action),
								)),
							const SizedBox(height: 16),
						],
					),
				),
			),
		);
	}

	static void _showCupertino(
		BuildContext context,
		List<ActionSheetItem> actions,
	) {
		showCupertinoModalPopup(
			context: context,
			builder: (sheetContext) => CupertinoActionSheet(
				actions: actions.map((action) => CupertinoActionSheetAction(
					isDestructiveAction: action.isDestructive,
					onPressed: () {
						Navigator.pop(sheetContext);
						action.onTap();
					},
					child: Text(action.title),
				)).toList(),
				cancelButton: CupertinoActionSheetAction(
					onPressed: () => Navigator.pop(sheetContext),
					child: const Text('Cancel'),
				),
			),
		);
	}

	static Widget _buildMaterialTile(
		BuildContext context,
		BuildContext sheetContext,
		ActionSheetItem action,
	) {
		final textColor = action.textColor ??
			(action.isDestructive ? theme.Palette.redColor : null);
		final iconColor = action.iconColor ??
			(action.isDestructive ? theme.Palette.redColor : null);

		return ListTile(
			leading: action.icon != null ? 
				Icon(
					action.icon,
					color: iconColor,
				) : null,
			title: Text(
				action.title,
				style: TextStyle(
					fontSize: 14,
					color: textColor,
					fontWeight: action.isDestructive ? FontWeight.bold : null,
				),
			),
			onTap: () {
				Navigator.pop(sheetContext);
				action.onTap();
			},
		);
	}

	static void _showCupertinoConfirmation(
		BuildContext context,
		String cancelTitle,
		String submitTitle,
		String title,
		String message,
		Future<void> Function() onSubmit,
	) {
		showCupertinoDialog(
			context: context,
			builder: (dialogContext) => CupertinoAlertDialog(
				title: Text(title),
				content: Padding(
					padding: const EdgeInsets.only(top: 8),
					child: Text(message),
				),
				actions: [
					CupertinoDialogAction(
						onPressed: () => Navigator.pop(dialogContext),
						child: Text(cancelTitle),
					),
					CupertinoDialogAction(
						isDestructiveAction: true,
						onPressed: () async {
							Navigator.pop(dialogContext);
							await _showLoadingAndSubmit(context, onSubmit);
						},
						child: Text(submitTitle),
					),
				],
			),
		);
	}

	static void _showMaterialConfirmation(
		BuildContext context,
		String cancelTitle,
		String submitTitle,
		String title,
		String message,
		Future<void> Function() onSubmit,
	) {
		showDialog(
			context: context,
			builder: (dialogContext) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(dialogContext),
						child: Text(cancelTitle),
					),
					TextButton(
						style: TextButton.styleFrom(
							foregroundColor: theme.Palette.redColor,
						),
						onPressed: () async {
							Navigator.pop(dialogContext);
							await _showLoadingAndSubmit(context, onSubmit);
						},
						child: Text(submitTitle),
					),
				],
			),
		);
	}

	static Future<void> _showLoadingAndSubmit(
		BuildContext context,
		Future<void> Function() onSubmit,
	) async {
		late BuildContext loadingContext;

		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (ctx) {
				loadingContext = ctx;
				return const Center(child: CircularProgressIndicator());
			},
		);

		await onSubmit();

		if (loadingContext.mounted) {
			Navigator.pop(loadingContext);
		}
	}
}