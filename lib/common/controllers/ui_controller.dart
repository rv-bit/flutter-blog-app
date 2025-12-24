import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

final scrollUIController = ScrollUIController();

const double kAppBarHeight = 70;
const double kAppBarLiftThreshold = 20; // used to determine the height of app bar when hidden

const double kBottomBarHeight = 50;
const double kFabBasePadding = 10;
const double kFabMaxLift = 30; 
const double kFabSize = 56;

enum BarVisibility { shown, hidden }

class ScrollUIController extends ChangeNotifier {
	BarVisibility _visibility = BarVisibility.shown;
	BarVisibility get visibility => _visibility;
	bool get isHidden => _visibility == BarVisibility.hidden;


	void onScroll(ScrollNotification notification) {
		if (notification is! UserScrollNotification) return;

		final direction = notification.direction;
		final metrics = notification.metrics;

		// 🔒 If content cannot scroll, ignore completely
		if (metrics.maxScrollExtent <= 0) return;

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
				// Do nothing
				break;
		}
	}

	void forceShow() {
		if (_visibility == BarVisibility.shown) return;
		_visibility = BarVisibility.shown;
		notifyListeners();
	}
}
