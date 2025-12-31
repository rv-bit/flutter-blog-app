import 'package:flutter/material.dart';

class StaticFAB extends StatelessWidget {
	final VoidCallback onPressed;
	final Widget icon;

	const StaticFAB({
		super.key,

		required this.onPressed,
		required this.icon,
	});

	@override
	Widget build(BuildContext context) {
		return FloatingActionButton(
			shape: RoundedSuperellipseBorder(
				borderRadius: BorderRadius.circular(30.0),
			),
			onPressed: onPressed,
			elevation: 0,
			child: icon,
		);
	}
}