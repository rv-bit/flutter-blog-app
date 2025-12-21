import 'package:go_router/go_router.dart';

import 'package:flutter_blog_app/app/shell.dart';
import 'package:flutter_blog_app/features/home/views/home_view.dart';

final appRouter = GoRouter(
	routes: [
		ShellRoute(
			builder: (context, state, child) {
				return AppShell(child: child);
			},
			routes: [
				GoRoute(
					path: '/',
					builder: (context, state) => HomeView(title: 'Home Page'),
				),
				GoRoute(
					path: '/search',
					builder: (context, state) => HomeView(title: 'Search Page'),
				),
			],
		),

		GoRoute(
			path: '/create',
			builder: (context, state) => HomeView(title: 'Create Page'),
		),
	],
);
