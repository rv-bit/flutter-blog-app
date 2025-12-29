import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
	final IndicatorState state;
	final double value;

	const Indicator({
		super.key,

		required this.state,
		required this.value,
	});


	@override
	Widget build(BuildContext context) {
		if (value > 0 && (!state.isArmed && !state.isLoading && !state.isFinalizing && !state.isSettling)) {
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
		if (state.isArmed || state.isLoading || state.isSettling || state.isFinalizing) {
			return const SizedBox(
				width: 15,
				height: 15,
				child: CupertinoActivityIndicator(
					color: Colors.white,
				),
			);
		}

		return const SizedBox.shrink();
	}
}