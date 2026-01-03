import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:carousel_slider/carousel_slider.dart';

Widget singleImage(BuildContext context, String base64) {
	return ClipRRect(
		borderRadius: BorderRadius.circular(12),
		child: Image.memory(
			base64Decode(base64),
			width: double.infinity,
			height: 300,
			fit: BoxFit.cover,
			gaplessPlayback: true,
		),
	);
}

Widget imageCarousel(BuildContext context, List<String> images) {
	final width = MediaQuery.of(context).size.width;

	return CarouselSlider(
		items: images.map((base64) {
			return Container(
				margin: const EdgeInsets.symmetric(horizontal: 5),
				child: ClipRRect(
					borderRadius: BorderRadius.circular(8.0),
					child: AspectRatio(
						aspectRatio: 1,
						child: Image.memory(
							base64Decode(base64),
							fit: BoxFit.cover,
							gaplessPlayback: true,
						),
					),
				),
			);
		}).toList(),
		options: CarouselOptions(
			height: width * 0.8,
			viewportFraction: 0.8,
			enableInfiniteScroll: false,
			padEnds: false,
		),
	);
}