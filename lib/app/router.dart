import 'package:go_router/go_router.dart';

import 'package:flutter_blog_app/app/shell.dart';

import 'package:flutter_blog_app/features/home/views/home_view.dart';
import 'package:flutter_blog_app/features/blog/views/create_blog_view.dart';

final appRouter = GoRouter(
	initialLocation: '/',
	routes: [
		ShellRoute(
			builder: (context, state, child) {
				return AppShell(child: child);
			},
			routes: [
				GoRoute(
					path: '/',
					builder: (context, state) => HomeView(),
				),
				GoRoute(
					path: '/search',
					builder: (context, state) => HomeView(),
				),
			],
		),

		GoRoute(
			path: '/create',
			builder: (context, state) => CreateBlogView(),
		),
	],
);
