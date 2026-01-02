import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_blog_app/app/shell.dart';

import 'package:flutter_blog_app/config/navigation_config.dart' as shell_navigations;

import 'package:flutter_blog_app/common/controllers/blog_checks_controller.dart';

import 'package:flutter_blog_app/features/blog/views/individual_blog_view.dart';
import 'package:flutter_blog_app/features/blog/views/create_blog_view.dart';
import 'package:flutter_blog_app/features/blog/views/edit_blog_view.dart';

// This code was taken from a stack overflow page, as wanted transitions for page / router changes, as go router currently doesn't support for this, the quickest and easier fix was this
CustomTransitionPage buildPageWithDefaultTransition<T>({
	required BuildContext context, 
	required GoRouterState state, 
	required Widget child,
}) {
	return CustomTransitionPage<T>(
		key: state.pageKey,
		child: child,
		transitionsBuilder: (context, animation, secondaryAnimation, child) {
			// Twitter-like slide transition
			const begin = Offset(1.0, 0.0); // Start from right
			const end = Offset.zero;
			const curve = Curves.easeInOut;

			var slideTween = Tween(begin: begin, end: end).chain(
				CurveTween(curve: curve),
			);

			var slideAnimation = animation.drive(slideTween);

			var secondaryScaleTween = Tween<double>(begin: 1.0, end: 0.95);

			return SlideTransition(
				position: slideAnimation,
				child: FadeTransition(
					opacity: Tween<double>(begin: 1.0, end: 1.0).animate(animation),
					child: Transform.scale(
						scale: secondaryScaleTween.evaluate(secondaryAnimation),
						child: child,
					),
				),
			);
		},
	);
}

final appRouter = GoRouter(
	initialLocation: '/',
	routes: [
		ShellRoute(
			builder: (context, state, child) {
				return AppShell(child: child);
			},
			routes: [
				...shell_navigations.ShellRoutes.values.map((tab) => GoRoute(
					name: tab.name,
					path: tab.path,
					pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
						context: context,
						state: state,
						child: tab.builder(),
					),
				)),
			],
		),

		GoRoute(
			name: 'create',
			path: '/create',
			pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
				context: context,
				state: state,
				child: CreateBlogView(),
			)
		),

		GoRoute(
			name: 'edit',
			path: '/edit/:blogId',
			redirect: (context, state) async {
				final blogId = state.pathParameters['blogId'];

				// invalid URL -> home should be 404 but no page exist
				if (blogId == null || blogId.isEmpty) {
					return '/';
				}

				final container = ProviderScope.containerOf(context);
				final exists = await container.read(blogExistsProvider(blogId).future);

				// invalid URL -> home should be 404 but no page exist
				if (!exists) {
					return '/';
				}

				return null;
			},
			pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
				context: context,
				state: state,
				child: EditBlogView(blogId: state.pathParameters['blogId']!),
			),
		),

		GoRoute(
			name: 'individual_blog',
			path: '/blog/:blogId',
			redirect: (context, state) async {
				final blogId = state.pathParameters['blogId'];

				// invalid URL -> home should be 404 but no page exist
				if (blogId == null || blogId.isEmpty) {
					return '/';
				}

				final container = ProviderScope.containerOf(context);
				final exists = await container.read(blogExistsProvider(blogId).future);

				// invalid URL -> home should be 404 but no page exist
				if (!exists) {
					return '/';
				}

				return null;
			},
			pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
				context: context,
				state: state,
				child: IndividualBlogView(blogId: state.pathParameters['blogId']!),
			),
		),
	],
);
