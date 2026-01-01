
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationController extends Notifier<int> {
	@override
	int build() => 0; // Default to home

	void setActiveTab(int index) {
		state = index;
	}
}

final navigationControllerProvider = NotifierProvider<NavigationController, int>(
	NavigationController.new,
);