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

	static const double _indicatorHeight = 56.0;
	static const double _offsetToArmed = 36.0;

	bool _showSpinner = false;
	bool _hasTriggeredArmedHaptic = false;

	double _dragDistance = 0.0;

	List<String> _items = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

	Future<void> _handleRefresh() async {
		// Delay spinner appearance (Twitter-like)
		await Future.delayed(const Duration(milliseconds: 200));

		if (mounted) {
			setState(() => _showSpinner = true);
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
		return Scaffold(
			body: Stack(
				children: [
					NotificationListener<ScrollNotification>(
						onNotification: (notification) {
							scrollUIController.onScroll(notification);

							if (notification is ScrollUpdateNotification) {
								if (notification.metrics.pixels <= 0) {
									final oldDistance = _dragDistance;
									_dragDistance -= notification.scrollDelta ?? 0;
									
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
							onRefresh: _handleRefresh,
							builder: (context, child, controller) {
								return AnimatedBuilder(
									animation: controller,
									builder: (context, _) {
										final rawValue = controller.value;
										final biased = (rawValue + (_dragDistance / _offsetToArmed) * 0.25)
											.clamp(0.0, 1.2);
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
															value: eased,
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
								top: _showSpinner ? _indicatorHeight : 15,
								bottom: kBottomBarHeight + MediaQuery.of(context).viewPadding.bottom + 16, // breathing room
							),
							itemCount: _items.length,
							itemBuilder: (_, i) => ListTile(
								title: Text('${widget.title} ${_items[i]}'),
							),
						),
					),
				),

				const GlassAppBar(),

				],
			),
		);
	}
}