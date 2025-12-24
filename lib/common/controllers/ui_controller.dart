import 'package:flutter/cupertino.dart';

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
		if (notification is! ScrollUpdateNotification) return;

		final delta = notification.scrollDelta ?? 0;

		// Down = hide
		if (delta > 0 && _visibility != BarVisibility.hidden) {
			_visibility = BarVisibility.hidden;
			notifyListeners();
		}

		// Up = show
		if (delta < 0 && _visibility != BarVisibility.shown) {
			_visibility = BarVisibility.shown;
			notifyListeners();
		}
	}

	void forceShow() {
		_visibility = BarVisibility.shown;
		notifyListeners();
	}
}
