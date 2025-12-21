import 'package:flutter/foundation.dart';

final scrollUIController = ScrollUIController();

const double kBottomBarHeight = 50;
const double kFabBasePadding = 30;
const double kFabMaxLift = 30; 

class ScrollUIController extends ChangeNotifier {
	double _offset = 0;
	final double _maxOffset = kBottomBarHeight + 20; // Make sure to cover padding

	double get offset => _offset;

	void update(double delta) {
		_offset = (_offset + delta * 0.8).clamp(0, _maxOffset);
		notifyListeners();
	}

	void snap() {
		_offset = _offset > _maxOffset / 2 ? _maxOffset : 0;
		notifyListeners();
	}
}