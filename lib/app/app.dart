import 'router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme.dart';

class App extends StatelessWidget {
	const App({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp.router(
			title: 'Offline Blog App',
			routerConfig: appRouter,
			theme: AppTheme.theme,
		);
	}
}
