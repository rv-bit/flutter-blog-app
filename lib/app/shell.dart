import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as utils;
import 'package:flutter_blog_app/common/controllers/index.dart' as controllers;
import 'package:flutter_blog_app/common/widgets/index.dart' as widgets;

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
						currentIndex: utils.locationToIndex(context),
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
		final totalHeight = controllers.kBottomBarHeight + bottomInset;

		return AnimatedBuilder(
			animation: controllers.scrollUIController,
			builder: (_, _) {
				return AnimatedPositioned(
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					bottom: controllers.scrollUIController.isHidden ? -totalHeight : 0,
					child: widgets.StaticBottomBar(
						currentIndex: currentIndex,
						onTap: (index) => onTap(context, index),
					),
				);
			},
		);
	}
}