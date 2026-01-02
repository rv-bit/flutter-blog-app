import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum BarVisibility { shown, hidden }

const double kAppBarHeight = 70;
const double kAppBarLiftThreshold = 5; // used to determine the height of app bar when hidden

const double kBottomBarHeight = 50; 
const double kFabBasePadding = 10; 
const double kFabMaxLift = 30; 
const double kFabSize = 56;

final globalInterfaceController = InterfaceController();

class InterfaceController extends ChangeNotifier {
	BarVisibility _visibility = BarVisibility.shown;
	BarVisibility get visibility => _visibility;
	bool get isHidden => _visibility == BarVisibility.hidden;

	// Track if refresh is in progress
	bool _isRefreshing = false;
	bool get isRefreshing => _isRefreshing;

	void setRefreshing(bool value) {
		if (_isRefreshing == value) return;
		_isRefreshing = value;
		
		// Always show bars when refreshing starts
		if (value && _visibility != BarVisibility.shown) {
			_visibility = BarVisibility.shown;
			notifyListeners();
		}
	}

	void onScroll(ScrollNotification notification) {
		if (notification is! UserScrollNotification) return;

		final direction = notification.direction;
		final metrics = notification.metrics;

		// If there is no content do not scroll the UI, ignore completely
		if (metrics.maxScrollExtent <= 0) return;

		if (_isRefreshing || metrics.pixels <= 10) {
			if (_visibility != BarVisibility.shown) {
				_visibility = BarVisibility.shown;
				notifyListeners();
			}
			return;
		}

		switch (direction) {
			case ScrollDirection.reverse:
				// User scrolls DOWN
				if (_visibility != BarVisibility.hidden) {
					_visibility = BarVisibility.hidden;
					notifyListeners();
				}
				break;

			case ScrollDirection.forward:
				// User scrolls UP
				if (_visibility != BarVisibility.shown) {
					_visibility = BarVisibility.shown;
					notifyListeners();
				}
				break;

			case ScrollDirection.idle:
				break;
		}
	}

	void forceShow() {
		if (_visibility == BarVisibility.shown) return;
		_visibility = BarVisibility.shown;
		notifyListeners();
	}
}