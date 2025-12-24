import 'package:flutter/material.dart';

import 'package:flutter_blog_app/common/controllers/ui_controller.dart';
import 'package:flutter_blog_app/features/home/widgets/appbar_widget.dart';

class HomeView extends StatefulWidget {
	final String title;

	const HomeView({super.key, required this.title});

	@override
	State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
	final ScrollController _controller = ScrollController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Stack(
			children: [
				Padding(
					padding: const EdgeInsets.only(top: 0.0),
					child: NotificationListener<ScrollNotification>(
						onNotification: (notification) {
							scrollUIController.onScroll(notification);
							return false;
						},
						child: ListView.builder(
							controller: _controller,
							itemCount: 50,
							itemBuilder: (_, i) => ListTile(
								title: Text('${widget.title} Item $i'),
							),
						),
					),
				),

				const GlassAppBar(), // <-- no Positioned, no offset
			],
		),
		);
	}
}