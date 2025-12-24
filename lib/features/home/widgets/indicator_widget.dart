import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
	final double value;
	final bool showSpinner;

	const Indicator({
		super.key,

		required this.value,
		required this.showSpinner,
	});

	@override
	Widget build(BuildContext context) {
		if (!showSpinner) {
			return Opacity(
				opacity: value,
				child: Transform.rotate(
					angle: 0,
					child: const Icon(
						Icons.keyboard_arrow_down,
						size: 28,
						color: Colors.white, // FORCE visibility
					),
				),
			);
		}

		// ARMED / LOADING → spinner
		if (showSpinner) {
			return const SizedBox(
				width: 22,
				height: 22,
				child: CircularProgressIndicator(
				strokeWidth: 2.2,
				color: Colors.white,
				),
			);
		}

		return const SizedBox.shrink();
	}
}