import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

int locationToIndex(BuildContext context) {
	final location = GoRouterState.of(context).uri.path;

	if (location.startsWith('/search')) return 1;
	return 0;
}
