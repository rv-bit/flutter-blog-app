import 'package:go_router/go_router.dart';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as utils;
import 'package:flutter_blog_app/common/controllers/index.dart' as controllers;
import 'package:flutter_blog_app/common/widgets/action_buttons_widget.dart' as widgets;

import 'package:flutter_blog_app/features/home/widgets/app_bar_widget.dart';
import 'package:flutter_blog_app/features/home/widgets/indicator_widget.dart';

class HomeView extends StatefulWidget {
	const HomeView({super.key});

	@override
	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
	final ScrollController _controller = ScrollController();

	static const double _indicatorHeight = 35.0;
	static const double _offsetToArmed = 15.0;

	bool _showSpinner = false;
	bool _hasTriggeredArmedHaptic = false;

	double _dragDistance = 0.0;

	List<String> _items = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

	Future<void> _handleRefresh() async {
		// Delay spinner appearance (Twitter-like)
		await Future.delayed(const Duration(milliseconds: 200));

		if (mounted) {
			setState(() {
				_showSpinner = true;
			});
		}

		await Future.delayed(const Duration(milliseconds: 800));

		if (mounted) {
			setState(() {
				_showSpinner = false;
			});
						
			// 🔔 Haptic on release/completion
			HapticFeedback.lightImpact();
		}

		_items = List.generate(50, (index) => 'Item $index');
	}

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;
		final currentIndex = utils.locationToIndex(context);

		return Stack(
			children: [
				NotificationListener<ScrollNotification>(
					onNotification: (notification) {
						controllers.scrollUIController.onScroll(notification);

						if (notification is ScrollUpdateNotification) {
							if (notification.metrics.pixels <= 0) {
								final oldDistance = _dragDistance;
								_dragDistance -= (notification.scrollDelta ?? 0) * 1.5;
								
								// 🔔 Haptic when first crossing armed threshold
								if (!_hasTriggeredArmedHaptic && oldDistance < _offsetToArmed &&  _dragDistance >= _offsetToArmed) {
									HapticFeedback.mediumImpact();
									_hasTriggeredArmedHaptic = true;
								}
							}
						}

						if (notification is ScrollEndNotification) {
							_hasTriggeredArmedHaptic = false;
							_dragDistance = 0;
						}
						
						return false;
					},

					child: CustomRefreshIndicator(
						offsetToArmed: _offsetToArmed,
						triggerMode: IndicatorTriggerMode.anywhere,
						onRefresh: _handleRefresh,
						onStateChanged: (change) {
							if (change.didChange(to: IndicatorState.dragging) || change.didChange(to: IndicatorState.armed) || change.didChange(to: IndicatorState.loading)) {
								controllers.scrollUIController.setRefreshing(true);
							} else if (change.didChange(to: IndicatorState.idle)) {
								controllers.scrollUIController.setRefreshing(false);
							}
						},
						builder: (context, child, controller) {
							return AnimatedBuilder(
								animation: controller,
								builder: (context, _) {
									final rawValue = controller.value;
									final dragContribution = (_dragDistance / _offsetToArmed) * 0.5;
									final biased = (rawValue + dragContribution).clamp(0.0, 1.5);
									final eased = Curves.easeOut.transform(biased.clamp(0.0, 1.0));
									
									return ClipRect(
										child: Stack(
										clipBehavior: Clip.none,
										children: [
											// Indicator (fixed under app bar)
											Positioned(
												top: controllers.kAppBarHeight + _indicatorHeight / 2,
												left: 0,
												right: 0,
												height: _indicatorHeight,
												child: Center(
													child: Indicator(
														value: rawValue > 0 ? eased : 0,
														showSpinner: _showSpinner,
													),
												),
											),

											// Scroll content (visual translation only)
											Transform.translate(
												offset: Offset(
													0,
													controllers.kAppBarHeight + _indicatorHeight * rawValue,
												),
												child: child,
											),
										],
									),
								);},
							);
						},
						
						child: ListView.builder(
							controller: _controller,
							physics: const AlwaysScrollableScrollPhysics(
								parent: BouncingScrollPhysics(),
							),
							padding: EdgeInsets.only(
								top: _showSpinner ? _indicatorHeight : 10,
								bottom: controllers.kBottomBarHeight + bottomInset + 15,
							),
							itemCount: _items.length,
							itemBuilder: (_, i) => ListTile(
								title: Text(' ${_items[i]}'),
							),
						),
					
					),
				),

				const CustomAppBar(),
				_AnimatedFAB(currentIndex: currentIndex)
			],
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
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return AnimatedBuilder(
			animation: controllers.scrollUIController,
			builder: (_, _) {
				return AnimatedPositioned(
					right: 15,
					bottom: controllers.scrollUIController.isHidden ? controllers.kFabSize / 5 + bottomInset : controllers.kBottomBarHeight + controllers.kFabBasePadding + bottomInset,
					duration: const Duration(milliseconds: 200),
					curve: Curves.easeIn,
					child: widgets.StaticFAB(
						onPressed: () => context.push('/create'),
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
