import 'package:flutter/widgets.dart';
import 'package:flutter_blog_app/constants/assets_constants.dart';
import 'package:flutter_blog_app/features/home/views/home_view.dart';

enum ShellRoutes {
	home(
		path: '/',
		name: 'home',
		builder: HomeView.new,
		activeIcon: AssetsConstants.homeFilledIcon,
    	inactiveIcon: AssetsConstants.homeOutlinedIcon,
	),
	search(
		path: '/search',
		name: 'search',
		builder: HomeView.new, // Or your SearchView
		activeIcon: AssetsConstants.searchIcon,
    	inactiveIcon: AssetsConstants.searchIcon,
	);

	final String path;
	final String name;
	final Widget Function() builder;

	final String activeIcon;
 	final String inactiveIcon;

	const ShellRoutes({
		required this.path, 
		required this.name,
		required this.builder,
		required this.activeIcon,
		required this.inactiveIcon
	});

	int get indexTab => ShellRoutes.values.indexOf(this);

	static ShellRoutes fromPath(String path) {
		return ShellRoutes.values.firstWhere((tab) => path.startsWith(tab.path),
			orElse: () => ShellRoutes.home,
		);
	}

	static ShellRoutes fromIndex(int index) {
		if (index < 0 || index >= ShellRoutes.values.length) {
			return ShellRoutes.home;
		}
		return ShellRoutes.values[index];
	}
}