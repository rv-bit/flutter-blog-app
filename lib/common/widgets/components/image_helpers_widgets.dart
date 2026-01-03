import 'package:flutter/widgets.dart';

import 'package:carousel_slider/carousel_slider.dart';

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
					// child: AspectRatio(
					// 	aspectRatio: 16.0/9.0,
						child: child
					// ),
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