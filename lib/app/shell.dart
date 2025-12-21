import 'package:flutter_blog_app/common/controllers/ui_controller.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/components_constants.dart';
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
			body: Stack(
				children: [
					child,

					const _AnimatedAppBar(),
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

class _AnimatedAppBar extends StatelessWidget {
	const _AnimatedAppBar();

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: scrollUIController,
			builder: (_, __) {
				return Positioned(
					top: -scrollUIController.offset,
					left: 0,
					right: 0,
					child: ComponentsConstants.appBar(),
				);
			},
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
				return Positioned(
					left: 0,
					right: 0,
					bottom: -scrollUIController.offset,
					child: CupertinoTabBar(
						height: kBottomBarHeight,
						currentIndex: currentIndex,
						onTap: (i) => onTap(context, i),
						items: [
							BottomNavigationBarItem(
								icon: SvgPicture.asset(
									currentIndex == 0
										? AssetsConstants.homeFilledIcon
										: AssetsConstants.homeOutlinedIcon,
									colorFilter: ColorFilter.mode(
										currentIndex == 0
											? Palette.whiteColor
											: Palette.greyColor,
										BlendMode.srcIn,
									),
								),
								label: 'Home',
							),
							BottomNavigationBarItem(
								icon: SvgPicture.asset(
									AssetsConstants.searchIcon,
									colorFilter: ColorFilter.mode(
										currentIndex == 1
											? Palette.whiteColor
											: Palette.greyColor,
										BlendMode.srcIn,
									),
								),
								label: 'Search',
							),
						],
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
				final offset = scrollUIController.offset;
				final cappedLift = Curves.easeOut.transform(
					(offset / kFabMaxLift).clamp(0, 1),
				) * kFabMaxLift;

				return Positioned(
					right: 15,
					bottom: kFabBasePadding + kBottomBarHeight - cappedLift,
					child: currentIndex == 0 ? FloatingActionButton(
						onPressed: () => context.go('/create'),
						tooltip: 'Create Post',
						shape: RoundedSuperellipseBorder(
							borderRadius: BorderRadius.circular(30.0),
						),
						child: SvgPicture.asset(
							AssetsConstants.blogInsert,
							colorFilter: ColorFilter.mode(Palette.whiteColor, BlendMode.srcIn),
							height: 24,
						),
					) : SizedBox.shrink(),
				);
			},
		);
	}
}
