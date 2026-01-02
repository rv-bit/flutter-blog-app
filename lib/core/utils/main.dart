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
	DateTime date;

	try {
		date = DateTime.parse(dateString);
	} catch (e) {
		return '';
	}

	final now = DateTime.now();
	final difference = now.difference(date);

	if (difference.inSeconds < 60) {
		return '${difference.inSeconds}s';
	} else if (difference.inMinutes < 60) {
    	return '${difference.inMinutes}m';
	} else if (difference.inHours < 24) {
		return '${difference.inHours}h';
	} else if (difference.inDays < 7) {
		return '${difference.inDays}d';
	} else {
		final day = date.day.toString().padLeft(2, '0');
		final month = date.month.toString().padLeft(2, '0');
		final year = date.year.toString();
		return '$day/$month/$year';
	}
}

String formatDate(
	String dateString, {
	bool showDate = false,
	bool showTime = false,
	bool showBoth = false,
}) {
	DateTime date;

	try {
		date = DateTime.parse(dateString);
	} catch (e) {
		return '';
	}

	final day = date.day.toString().padLeft(2, '0');
	final month = date.month.toString().padLeft(2, '0');
	final year = date.year.toString();

	final hour = date.hour.toString().padLeft(2, '0');
	final minute = date.minute.toString().padLeft(2, '0');

	if (showDate) {
		return '$day/$month/$year';
	} else if (showTime) {
		return '$hour:$minute';
	} else if (showBoth) {
		return '$hour:$minute · $day/$month/$year';
	}

	return '';
}