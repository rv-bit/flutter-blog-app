import 'dart:ui';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;

class AppBar extends StatelessWidget {
	final bool isSelectionMode;
	final int selectedCount;
	final int totalCount;
	final VoidCallback? onEnterSelectionMode;
	final VoidCallback? onExitSelectionMode;
	final VoidCallback? onSelectAll;
	final VoidCallback? onDeselectAll;
	final VoidCallback? onDelete;

	const AppBar({
		super.key,
		this.isSelectionMode = false,
		this.selectedCount = 0,
		this.totalCount = 0,
		this.onEnterSelectionMode,
		this.onExitSelectionMode,
		this.onSelectAll,
		this.onDeselectAll,
		this.onDelete,
	});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: common_controllers.scrollUIController,
			builder: (context, _) {
				final topInset = MediaQuery.of(context).viewPadding.top;
				final totalHeight = common_controllers.kAppBarHeight + topInset;
				
				return AnimatedPositioned(
					top: common_controllers.scrollUIController.isHidden ? -totalHeight : 0,
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: ClipRect(
						child: BackdropFilter(
							filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
							child: Container(
								decoration: BoxDecoration(
									color: Palette.backgroundColor.withValues(alpha: 0.5),
									border: Border(
										bottom: BorderSide(
											color: Palette.greyColor.withValues(alpha: 0.2),
										),
									),
								),
								child: SafeArea(
									bottom: false,
									child: SizedBox(
										height: common_controllers.kAppBarHeight,
										child: isSelectionMode 
											? _buildSelectionAppBar(context)
											: _buildNormalAppBar(context),
									),
								),
							),
						)
					),
				);
			},
		);
	}

	Widget _buildNormalAppBar(BuildContext context) {
		return SizedBox(
			height: kToolbarHeight,
			child: Stack(
				alignment: Alignment.center,
				children: [
					// Center logo (true center)
					Center(
						child: SvgPicture.asset(
							AssetsConstants.logoIcon,
							height: 25,
						),
					),

					// Left action
					Align(
						alignment: Alignment.centerLeft,
						child: onEnterSelectionMode != null ? 
							IconButton(
								icon: const Icon(Icons.checklist_rounded, size: 24),
								onPressed: onEnterSelectionMode,
								tooltip: 'Select posts',
							) : const SizedBox.shrink(),
					),
				],
			),
		);
	}


	Widget _buildSelectionAppBar(BuildContext context) {
		final allSelected = selectedCount == totalCount && totalCount > 0;

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 8),
			child: Row(
				children: [
					IconButton(
						icon: const Icon(Icons.close, size: 24),
						onPressed: onExitSelectionMode,
						tooltip: 'Cancel',
					),
					const SizedBox(width: 8),
					Expanded(
						child: Text(
							'$selectedCount selected',
							style: const TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w600,
							),
						),
					),
					if (totalCount > 0) ...[
						IconButton(
							icon: Icon(
								allSelected ? Icons.deselect : Icons.select_all,
								size: 22,
							),
							onPressed: allSelected ? onDeselectAll : onSelectAll,
							tooltip: allSelected ? 'Deselect all' : 'Select all',
						),
					],
					IconButton(
						icon: Icon(
							Icons.delete_outline,
							size: 22,
							color: selectedCount > 0 ? Colors.red : Colors.grey,
						),
						onPressed: selectedCount > 0 ? onDelete : null,
						tooltip: 'Delete',
					),
				],
			),
		);
	}
}