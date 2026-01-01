import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_blog_app/config/navigation_config.dart';

int locationToIndex(BuildContext context) {
	final location = GoRouterState.of(context).uri.path;
	return ShellRoutes.fromPath(location).index;
}

void onNavItemTapped(BuildContext context, int index) {
	context.go(ShellRoutes.fromIndex(index).path);
}

String formatPostTime(String dateString) {
	DateTime postDate;

	try {
		postDate = DateTime.parse(dateString);
	} catch (e) {
		return '';
	}

	final now = DateTime.now();
	final difference = now.difference(postDate);

	if (difference.inSeconds < 60) {
		return '${difference.inSeconds}s';
	} else if (difference.inMinutes < 60) {
    	return '${difference.inMinutes}m';
	} else if (difference.inHours < 24) {
		return '${difference.inHours}h';
	} else if (difference.inDays < 7) {
		return '${difference.inDays}d';
	} else {
		final day = postDate.day.toString().padLeft(2, '0');
		final month = postDate.month.toString().padLeft(2, '0');
		final year = postDate.year.toString();
		return '$day-$month-$year';
	}
}
