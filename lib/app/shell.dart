import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/config/navigation_config.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

class AppShell extends ConsumerStatefulWidget {
	final Widget child;
	const AppShell({super.key, required this.child});

	@override
	ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
	@override
	void initState() {
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (mounted) {
				final currentIndex = common_utils.locationToIndex(context);
				ref.read(common_controllers.navigationControllerProvider.notifier).setActiveTab(currentIndex);
			}
		});
	}
	
	void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
		ref.read(common_controllers.navigationControllerProvider.notifier).setActiveTab(index);
		context.go(ShellRoutes.fromIndex(index).path);
	}

	@override
	Widget build(BuildContext context) {
		final activeTabIndex = ref.watch(common_controllers.navigationControllerProvider);

		return Scaffold(
			resizeToAvoidBottomInset: false,
			body: Stack(
				children: [
					widget.child, // The routed content
					_AnimatedBottomBar(
						onTap: (index) => _onItemTapped(context, ref, index),
						currentIndex: activeTabIndex,
					),
				],
			),
		);
	}
}

class _AnimatedBottomBar extends StatelessWidget {
	final int currentIndex;
	final void Function(int) onTap;

	const _AnimatedBottomBar({
		required this.currentIndex,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;
		final totalHeight = common_controllers.kBottomBarHeight + bottomInset;

		return AnimatedBuilder(
			animation: common_controllers.scrollUIController,
			builder: (_, _) {
				return AnimatedPositioned(
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					bottom: common_controllers.scrollUIController.isHidden ? -totalHeight : 0,
					child: common_widgets.StaticBottomBar(
						currentIndex: currentIndex,
						onTap: onTap,
					),
				);
			},
		);
	}
}