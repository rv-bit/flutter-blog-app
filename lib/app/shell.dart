import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';
import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/components_constants.dart' as components;
import 'package:flutter_blog_app/constants/assets_constants.dart';

class AppShell extends StatelessWidget {
	final Widget child;
	const AppShell({super.key, required this.child});
	
	int _locationToIndex(BuildContext context) {
		final location = GoRouterState.of(context).uri.path;

		if (location.startsWith('/search')) return 1;
		return 0;
	}

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
		final currentIndex = _locationToIndex(context);

		return Scaffold(
			resizeToAvoidBottomInset: false,
			body: Stack(
				children: [
					child,
					_AnimatedBottomBar(
						onTap: _onItemTapped,
						currentIndex: _locationToIndex(context),
					),
					_AnimatedFAB(
						currentIndex: currentIndex,
					),
				],
			), // The route the user is currently on, also known as the outlet
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
		return AnimatedBuilder(
			animation: scrollUIController,
			builder: (_, __) {
				return AnimatedPositioned(
					left: 0,
					right: 0,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					bottom: scrollUIController.isHidden ? -(kBottomBarHeight + MediaQuery.of(context).viewPadding.bottom) : 0,
					child: components.StaticBottomBar(
						currentIndex: currentIndex,
						onTap: (index) => onTap(context, index),
					),
				);
			},
		);
	}
}

class _AnimatedFAB extends StatelessWidget {
	final int currentIndex;
	const _AnimatedFAB({
		required this.currentIndex,
	});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: scrollUIController,
			builder: (_, __) {

				return AnimatedPositioned(
					right: 15,
					bottom: scrollUIController.isHidden ? -kFabSize + MediaQuery.of(context).viewPadding.bottom : kBottomBarHeight,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: components.StaticFAB(
						onPressed: () => context.go('/create'),
						icon: SvgPicture.asset(
							AssetsConstants.blogInsert,
							colorFilter: ColorFilter.mode(Palette.whiteColor, BlendMode.srcIn),
							height: 24,
						),
					),
				);
			},
		);
	}
}
