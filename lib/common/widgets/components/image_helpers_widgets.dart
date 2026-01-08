import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_blog_app/config/theme/index.dart' as theme;

Widget imageTile({
	required Widget image,
	Widget? overlay,
	BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
}) {
	return Stack(
		children: [
			ClipRRect(
				borderRadius: borderRadius,
				child: image,
			),
			if (overlay != null) overlay,
		],
	);
}

Widget imageCarousel(BuildContext context, List<Widget> items) {
	final width = MediaQuery.of(context).size.width;

	return CarouselSlider(
   		items: items.map((child) {
			return Container(
				width: width,
				margin: const EdgeInsets.symmetric(horizontal: 5),
					child: child
			);
		}).toList(),
		options: CarouselOptions(
			height: 400,
			viewportFraction: 0.8,
			enableInfiniteScroll: false,
			padEnds: false,
		),
	);
}

Widget removeButtonOverlay(VoidCallback onTap) {
	return Positioned(
		top: 5,
		right: 15,
		child: GestureDetector(
			onTap: onTap,
			child: Container(
				decoration: BoxDecoration(
					color: theme.Palette.backgroundColor.withValues(alpha: 0.6),
					shape: BoxShape.circle,
				),
				padding: const EdgeInsets.all(6),
				child: const Icon(Icons.close, size: 18, color: theme.Palette.whiteColor),
			),
		),
	);
}