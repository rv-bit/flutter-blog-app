import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/common/controllers/index.dart' as common_controllers;

import 'package:flutter_blog_app/common/widgets/components/indicator_widget.dart';

import '../widgets/blog_widgets/blog_list_items_widget.dart';
import '../widgets/navigation/action_buttons_widget.dart';
import '../widgets/navigation/app_bars/search_bar_widget.dart';

import '../controllers/home_controller.dart';
import '../controllers/search_controller.dart';

final interfaceController = common_controllers.InterfaceController();

class SearchView extends ConsumerStatefulWidget {
	const SearchView({super.key});

	@override
	ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
	final ScrollController _controller = ScrollController();
	final TextEditingController _searchController = TextEditingController();

	final ValueNotifier<Widget?> _headerNotifier = ValueNotifier<Widget?>(const SizedBox.shrink());

	static const double _indicatorHeight = 40.0;
	static const double _offsetToArmed = 30.0;

	bool _hasTriggeredArmedHaptic = false;
	double _dragDistance = 0.0;


	@override
	void initState() {
		super.initState();

		_controller.addListener(() {
			final query = ref.read(searchQueryProvider);
			final notifier = ref.read(searchResultsProvider(query).notifier);

			if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
				if (notifier.hasMore && !notifier.isLoadingMore) {
					notifier.loadMore();
				}
			}
		});
	}

	@override
	void dispose() {
		_controller.dispose();
		_searchController.dispose();
		_headerNotifier.dispose();

		super.dispose();
	}

	Future<void> _handleRefresh() async {
		final query = ref.read(searchQueryProvider);
		await ref.read(searchResultsProvider(query).notifier).refresh();
	}

	@override
	Widget build(BuildContext context) {
		final bottomMediaInset = MediaQuery.of(context).viewPadding.bottom;
		final topMediaInset = MediaQuery.of(context).padding.top;
		final topInset = common_controllers.kAppBarHeight + topMediaInset + 5.0;

		final query = ref.watch(searchQueryProvider);
		final blogState = ref.watch(searchResultsProvider(query));
		final blogs = blogState.asData?.value;

		late Widget blogListChild;

		blogListChild = BlogList(
			scrollController: _controller,
			blogs: blogState.asData?.value ?? [],
			indicatorHeight: _indicatorHeight,
			headerNotifier: _headerNotifier,
			padding: EdgeInsets.only(
				top: topInset,
				bottom: common_controllers.kBottomBarHeight + bottomMediaInset,
			),
		);

		if (blogs != null && blogs.isEmpty) {
			blogListChild = _blogsEmptyFallback();
		}

		return Stack(
			children: [
				NotificationListener<ScrollNotification>(
					onNotification: (notification) {
						if (notification.metrics.axis == Axis.vertical && notification.depth == 0) {
							interfaceController.onScroll(notification);

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
						}

						// Stop this event on other scrollable, only do it for the ListView, as needed for the pull to refresh
						return true;
					},

					child: CustomRefreshIndicator(
						offsetToArmed: _offsetToArmed,
						triggerMode: IndicatorTriggerMode.anywhere,
						onRefresh: _handleRefresh,
						onStateChanged: (change) {
							if (change.didChange(to: IndicatorState.dragging) || change.didChange(to: IndicatorState.armed) || change.didChange(to: IndicatorState.loading)) {
								interfaceController.setRefreshing(true);
							} else if (change.didChange(to: IndicatorState.idle)) {
								interfaceController.setRefreshing(false);
								_headerNotifier.value = const SizedBox.shrink();
							}
						},

						child: blogListChild,
						builder: (context, child, controller) {
							return AnimatedBuilder(
								animation: controller,
								builder: (context, _) {
									final rawValue = controller.value;
									final dragContribution = (_dragDistance / _offsetToArmed) * 0.9;
									final biased = (rawValue + dragContribution).clamp(0.0, 1.5);
									final eased = Curves.easeOut.transform(biased.clamp(0.0, 1.0));

									final expandFactor = (rawValue > 0 ? eased : 0.0).clamp(0.0, 1.0);
									final headerHeight = expandFactor * _indicatorHeight;

									final headerWidgetLoadingIndicator = SizedBox(
										height: headerHeight,
										child: Center(
											child: IgnorePointer(
												ignoring: true,
												child: Indicator(
													state: controller.state,
													value: rawValue > 0 ? eased : 0,
												),
											),
										),
									);

									// Update header notifier so BlogList's header updates.
									_headerNotifier.value = headerWidgetLoadingIndicator;

									return blogState.when(
										data: (blogs) {
											// Data is ready: return the same child instance, that was passed to CustomRefreshIndicator.child.
											return child;
										},
										loading: () {
											// While loading, show a centered loader. You can also choose to
											// return child! (the list) with an internal loader header if you prefer.
											return Center(
												child: Padding(
													padding: EdgeInsets.only(top: common_controllers.kAppBarHeight + 50),
													child: const CircularProgressIndicator(),
												),
											);
										},
										error: (err, stack) {
											return Center(
												child: Padding(
													padding: EdgeInsets.only(top: common_controllers.kAppBarHeight + 50),
													child: Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Icon(Icons.error_outline, size: 64, color: theme.AppTheme.theme.colorScheme.error),
															const SizedBox(height: 16),
															Text('Error loading blogs', style: theme.AppTheme.theme.textTheme.titleMedium),
															ElevatedButton.icon(
																onPressed: () => ref.invalidate(homeViewProvider),
																icon: const Icon(Icons.refresh),
																label: const Text('Retry'),
															),
														],
													),
												),
											);
										},
									);
								},
							);
						},
					),
				),

				AppBar(
					interfaceController: interfaceController,
					searchController: _searchController,
				),
				const AnimatedFAB(),
			],
		);
	}

	Widget _blogsEmptyFallback() {
		return Center(
			child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(
						Icons.article_outlined,
						size: 64,
						color: theme.AppTheme.theme.colorScheme.onSurface.withAlpha(80),
					),
					const SizedBox(height: 16),
					Text(
						'No blogs found',
						style: theme.AppTheme.theme.textTheme.titleMedium?.copyWith(color: theme.AppTheme.theme.colorScheme.onSurface.withAlpha(120)),
					),
				],
			),
		);
	}
}
