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
				child: AnimatedRotation(
					turns: value == 1.0 ? 0.5 : 0.0, // 0.5 turns = 180°
					duration: const Duration(milliseconds: 150),
					child: const Icon(
						Icons.arrow_downward_rounded,
						size: 28,
						color: Colors.white,
					),
				),
			);
		}

		// ARMED / LOADING → spinner
		if (showSpinner) {
			return const SizedBox(
				width: 15,
				height: 15,
				child: CircularProgressIndicator(
					strokeWidth: 2.2,
					color: Colors.white,
				),
			);
		}

		return const SizedBox.shrink();
	}
}