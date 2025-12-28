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
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return SafeArea(
			bottom: true,
			child: Container(
				margin: EdgeInsets.only(bottom: bottomInset / 2),
				child: FloatingActionButton(
					shape: RoundedSuperellipseBorder(
						borderRadius: BorderRadius.circular(30.0),
					),
					onPressed: onPressed,
					elevation: 0,
					child: icon,
				),
			),
		);
	}
}