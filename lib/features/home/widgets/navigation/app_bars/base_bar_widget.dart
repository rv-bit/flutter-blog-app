import 'dart:ui';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;

class AppBar extends ConsumerStatefulWidget {
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
    ConsumerState<AppBar> createState() => _AppBarState();
}

class _AppBarState extends ConsumerState<AppBar> {
	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: common_controllers.globalInterfaceController,
			builder: (context, _) {
				final topInset = MediaQuery.of(context).viewPadding.top;
				final totalHeight = common_controllers.kAppBarHeight + topInset;
				
				return AnimatedPositioned(
					top: common_controllers.globalInterfaceController.isHidden ? -totalHeight : 0,
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: ClipRect(
						child: BackdropFilter(
							filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
							child: Container(
								decoration: BoxDecoration(
									color: theme.Palette.backgroundColor.withValues(alpha: 0.5),
									border: Border(
										bottom: BorderSide(
											color: theme.Palette.greyColor.withValues(alpha: 0.2),
										),
									),
								),
								child: SafeArea(
									bottom: false,
									child: SizedBox(
										height: common_controllers.kAppBarHeight,
										child: widget.isSelectionMode
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
					Center(
						child: SvgPicture.asset(
							AssetsConstants.logoIcon,
							height: 25,
						),
					),

					Align(
						alignment: Alignment.centerLeft,
						child: widget.onEnterSelectionMode != null ? 
							IconButton(
								icon: const Icon(Icons.checklist_rounded, size: 24),
								onPressed: widget.onEnterSelectionMode,
								tooltip: 'Select posts',
							) : const SizedBox.shrink(),
					),

					Align(
						alignment: Alignment.centerRight,
						child: Padding(
							padding: const EdgeInsets.only(right: 5, left: 15),
							child: common_widgets.BlogFilterButton(
								initialOptions: ref.read(homeViewProvider.notifier).currentFilter,
								onApply: (options) {
									ref.read(homeViewProvider.notifier).applyFilters(options);
								},
							),
						)
				),
				],
			),
		);
	}

	Widget _buildSelectionAppBar(BuildContext context) {
		final allSelected = widget.selectedCount == widget.totalCount && widget.totalCount > 0;

		return  Row(
			children: [
				IconButton(
					icon: const Icon(Icons.close, size: 24),
					onPressed: widget.onExitSelectionMode,
					tooltip: 'Cancel',
				),

				Expanded(
					child: Text(
						'${widget.selectedCount} selected',
						style: const TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.w600,
						),
					),
				),

				if (widget.totalCount > 0) ...[
					IconButton(
						icon: Icon(
							allSelected ? Icons.deselect : Icons.select_all,
							size: 22,
						),
						onPressed: allSelected ? widget.onDeselectAll : widget.onSelectAll,
						tooltip: allSelected ? 'Deselect all' : 'Select all',
					),
				],

				IconButton(
					icon: Icon(
						Icons.delete_outline,
						size: 22,
						color: widget.selectedCount > 0 ? Colors.red : Colors.grey,
					),
					onPressed: widget.selectedCount > 0 ? widget.onDelete : null,
					tooltip: 'Delete',
				),
			],
		);
	}
}