import 'dart:math';
import 'package:flutter/material.dart';

class CharacterLimitIndicator extends StatelessWidget {
	final int currentLength;
	final int maxLength;
	final double size;

	const CharacterLimitIndicator({
		super.key,

		required this.currentLength,
		required this.maxLength,

		this.size = 30.0,
	});

	@override
	Widget build(BuildContext context) {
		final progress = currentLength / maxLength;
		final remaining = maxLength - currentLength;
		
		// Color logic similar to Twitter
		Color getProgressColor() {
			if (remaining <= 0) {
				return Colors.red; // Over limit
			} else if (remaining <= 20) {
				return Colors.orange; // Warning zone
			} else if (currentLength > 0) {
				return Colors.blue; // Normal typing
			}
			return Colors.grey.withValues(alpha: 0.5);
		}

		// Show number when close to limit
		bool showRemainingCount = remaining <= 20;

		return SizedBox(
			width: size,
			height: size,
			child: Stack(
				alignment: Alignment.center,
				children: [
					// Background circle
					CustomPaint(
						size: Size(size, size),
						painter: CircularProgressPainter(
							progress: 1.0,
							color: Colors.grey.withOpacity(0.2),
							strokeWidth: 2.5,
						),
					),

					CustomPaint(
						size: Size(size, size),
						painter: CircularProgressPainter(
							progress: progress.clamp(0.0, 1.0),
							color: getProgressColor(),
							strokeWidth: 2.5,
						),
					),

					if (showRemainingCount)
						Text(
							remaining.toString(),
							style: TextStyle(
								fontSize: 10,
								fontWeight: FontWeight.bold,
								color: getProgressColor(),
							),
						),
				],
			),
		);
	}
}

class CircularProgressPainter extends CustomPainter {
	final double progress;
	final Color color;
	final double strokeWidth;

	CircularProgressPainter({
		required this.progress,
		required this.color,
		required this.strokeWidth,
	});

	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()
		..color = color
		..strokeWidth = strokeWidth
		..style = PaintingStyle.stroke
		..strokeCap = StrokeCap.round;

		final center = Offset(size.width / 2, size.height / 2);
		final radius = (size.width - strokeWidth) / 2;

		// Start from top (-90 degrees = -pi/2 radians)
		const startAngle = -pi / 2;
		final sweepAngle = 2 * pi * progress;

		canvas.drawArc(
			Rect.fromCircle(center: center, radius: radius),
			startAngle,
			sweepAngle,
			false,
			paint,
		);
	}

	@override
	bool shouldRepaint(CircularProgressPainter oldDelegate) {
		return oldDelegate.progress != progress || oldDelegate.color != color;
	}
}