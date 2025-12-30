import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class Indicator extends StatelessWidget {
  	final IndicatorState? state;
  	final double value;

	const Indicator({
		super.key,

		required this.state,
		required this.value,
	});

	@override
	Widget build(BuildContext context) {
		final st = state;
		final bool isActiveArrow = value > 0 && value < 0.8 && !(st?.isArmed == true || st?.isLoading == true || st?.isFinalizing == true || st?.isSettling == true);
  		final iconSwitchValue = value >= 0.6;
		
		if (isActiveArrow) {
			return Opacity(
				opacity: value,
				child: AnimatedSwitcher(
					duration: const Duration(milliseconds: 200),
					switchInCurve: Curves.easeOut,
					switchOutCurve: Curves.easeIn,
					layoutBuilder: (child, widgets) => Stack(
						alignment: Alignment.center,
						children: <Widget>[...widgets, if (child != null) child],
					),
					transitionBuilder: (child, animation) {
						// You can combine fade+scale (or rotate) for a nice effect:
						return FadeTransition(
							opacity: animation,
							child: ScaleTransition(scale: animation, child: child),
						);
					},
					child: Icon(
						iconSwitchValue ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
						// Give a ValueKey so AnimatedSwitcher knows which widget is new
						key: ValueKey<bool>(iconSwitchValue),
						size: 28,
						color: Colors.white,
					),
				),
			);
		}

		// ARMED / LOADING → spinner
		if (value > 0.8 || st?.isArmed == true || st?.isLoading == true || st?.isSettling == true || st?.isFinalizing == true) {
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