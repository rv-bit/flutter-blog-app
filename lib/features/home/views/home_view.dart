import 'package:flutter/material.dart';
import 'package:flutter_blog_app/common/controllers/ui_controller.dart';

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
		return NotificationListener<ScrollNotification>(
			onNotification: (notification) {
				if (notification is ScrollUpdateNotification) {
					final delta = notification.scrollDelta ?? 0;
					scrollUIController.update(delta);
				}

				if (notification is ScrollEndNotification) {
					scrollUIController.snap();
				}

				return false;
			},
			child: ListView.builder(
				controller: _controller,
				itemCount: 50,
				itemBuilder: (_, i) => Material(
					child: ListTile(
						title: Text('${widget.title} Item $i'),
					),
				),
			),
		);
	}
}