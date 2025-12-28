import 'package:flutter/material.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/services.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';
import 'package:flutter_blog_app/features/home/widgets/appbar_widget.dart';
import 'package:flutter_blog_app/features/home/widgets/indicator_widget.dart';

class HomeView extends StatefulWidget {
	final String title;

	const HomeView({super.key, required this.title});

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

		return Stack(
			children: [
				NotificationListener<ScrollNotification>(
					onNotification: (notification) {
						scrollUIController.onScroll(notification);

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
								scrollUIController.setRefreshing(true);
							} else if (change.didChange(to: IndicatorState.idle)) {
								scrollUIController.setRefreshing(false);
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
												top: kAppBarHeight + _indicatorHeight / 2,
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
													kAppBarHeight + _indicatorHeight * rawValue,
												),
												child: child,
											),
										],
									),
								);
							},
						);
					},
						
					child: ListView.builder(
						controller: _controller,
						physics: const AlwaysScrollableScrollPhysics(
							parent: BouncingScrollPhysics(),
						),
						padding: EdgeInsets.only(
							top: _showSpinner ? _indicatorHeight : 10,
							bottom: kBottomBarHeight + bottomInset + 15,
						),
						itemCount: _items.length,
						itemBuilder: (_, i) => ListTile(
							title: Text('${widget.title} ${_items[i]}'),
						),
					),
				),
			),

			const CustomAppBar(),
			],
		);
	}
}