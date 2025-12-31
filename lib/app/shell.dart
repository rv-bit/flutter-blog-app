import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

class AppShell extends StatelessWidget {
	final Widget child;
	const AppShell({super.key, required this.child});

	void _onItemTapped(BuildContext context, int index) {
		switch (index) {
			case 0:
				context.go('/');
				break;
			case 1:
				context.go('/search');
				break;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			resizeToAvoidBottomInset: false,
			body: Stack(
				children: [
					child, // The routed content
					_AnimatedBottomBar(
						onTap: _onItemTapped,
						currentIndex: common_utils.locationToIndex(context),
					),
				],
			),
		);
	}
}

class _AnimatedBottomBar extends StatelessWidget {
	final int currentIndex;
	final void Function(BuildContext, int) onTap;

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
						onTap: (index) => onTap(context, index),
					),
				);
			},
		);
	}
}