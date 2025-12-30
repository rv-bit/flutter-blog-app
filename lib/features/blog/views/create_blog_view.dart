import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/constants/assets_constants.dart';
import 'package:flutter_blog_app/config/theme_pallet.dart';

import 'package:flutter_blog_app/core/utils/index.dart' as utils;

import 'package:flutter_blog_app/features/blog/widgets/character_indicator_widget.dart';

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';
import 'package:flutter_blog_app/features/blog/controllers/blog_add_controller.dart';

class CreateBlogView extends ConsumerStatefulWidget {
	const CreateBlogView({super.key});

  	@override ConsumerState<ConsumerStatefulWidget> createState() => _CreateBlogViewState();
}

class _CreateBlogViewState extends ConsumerState<CreateBlogView> {
	final blogTextBlockController = TextEditingController();
	bool _textInField = false;

	static const int maxCharacters = 100;
	int _currentCharCount = 0;

	List<File> images = [];

	@override
	void dispose() {
		super.dispose();
		blogTextBlockController.dispose();
	}

	void onPickImages() async {
		List<File> pickedImages = await utils.pickImages();
		setState(() {
			images = [...images, ...pickedImages];
		});
	}

	void onPickImageFromCamera() async {
		File? pickedImage = await utils.pickImageCamera();
		if (pickedImage != null) {
			setState(() {
				images.add(pickedImage);
			});
		}
	}

	void onPostBlog(bool isPosting) async {
		if (isPosting) return;

		final router = GoRouter.of(context);

		await ref.read(createBlogProvider.notifier).createBlog(
			content: blogTextBlockController.text,
			imageFiles: images,
		);

		if (!mounted) return;
		
		ref.read(homeViewProvider.notifier).refresh();
		router.pop();
	}

	@override
	Widget build(BuildContext context) {
		final createState = ref.watch(createBlogProvider);
		final isPosting = createState.isLoading;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Palette.backgroundColor,
				leading: IconButton(
					onPressed: () {
						if (context.canPop()) {
							context.pop();
						} else {
							context.go('/'); // Navigate to home if no previous route
						}
					},
					icon: const Icon(Icons.close, size: 25),
				),
				title: GestureDetector(
					onTap: () => onPostBlog(isPosting),
					child: Container(
						alignment: Alignment.centerRight,
						child: Opacity(
							opacity: !_textInField ? 0.5 : 1.0,
							child: Container(
								width: 60,
								height: 30,
								alignment: Alignment.center,
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(15),
									color: Palette.blueColor,
								),
								child: Padding(
									padding: const EdgeInsets.only(left: 5, right: 5),
									child: Text(
										'Post',
										textAlign: TextAlign.center,
										style: const TextStyle(
											fontSize: 14,
											fontWeight: FontWeight.bold,
										),
									),
								) 
							)
						),
					),
				),
			),
			body: SafeArea(
				child: SingleChildScrollView(
					child: Column(
						children: [
							Padding(
								padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Padding(
											padding: const EdgeInsets.only(top: 9),
											child: CircleAvatar(
												backgroundColor: Palette.blueColor,
												radius: 15,
											),
										),

										const SizedBox(width: 8),
										Expanded(
											child: TextField(
												controller: blogTextBlockController,
												onChanged: (val) => {
													setState(() {
														_currentCharCount = val.length;
														_textInField = val.isNotEmpty;
													})
												},
												maxLength: maxCharacters,
												style: const TextStyle(
													fontSize: 15,
												),
												textAlignVertical: TextAlignVertical.top,
												decoration: const InputDecoration(
													counterText: "", // hides the auto maxLength from TextField
													hintText: "What's happening?",
													hintStyle: TextStyle(
														color: Palette.greyColor,
														fontSize: 15,
														fontWeight: FontWeight.w300,
													),
													border: InputBorder.none,
													isDense: false,
												),
												maxLines: null,
											),
										),
									],
								),
							),

							if (images.isNotEmpty) 
								CarouselSlider(
									items: images.map((file) {
										return Container(
											width: MediaQuery.of(context).size.width,
											margin: const EdgeInsets.symmetric(
												horizontal: 5,
											),
											child: Image.file(file),
										);
									}).toList(),
									options: CarouselOptions(
										height: 400,
										enableInfiniteScroll: false,
									),
								),
								const SizedBox(height: 80),
						],
					),
				),
			),
			bottomNavigationBar: Transform.translate(
				offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
				child: Container(
					padding: const EdgeInsets.only(bottom: 10),
					decoration: BoxDecoration(
						border: Border(
							top: BorderSide(color: Palette.greyColor.withValues(alpha: 0.5))
						),
						color: Palette.backgroundColor
					),
					child: SafeArea(
						top: false,
						child: Row(
							children: [
								Padding(
									padding: const EdgeInsets.all(8.0).copyWith(
										left: 15,
										right: 15,
									),
									child: GestureDetector(
										onTap: onPickImages,
										child: SvgPicture.asset(
											AssetsConstants.addImageIcon,
											colorFilter: ColorFilter.mode(
												Palette.blueColor,
												BlendMode.srcIn
											),
											height: 24,		
										),
									),
								),
								Padding(
									padding: const EdgeInsets.all(8.0).copyWith(
										left: 0,
										right: 15,
									),
									child: GestureDetector(
										onTap: onPickImageFromCamera,
										child: SvgPicture.asset(
											AssetsConstants.camera,
											colorFilter: ColorFilter.mode(
												Palette.blueColor,
												BlendMode.srcIn
											),
											height: 20,	
										),
									),
								),
								
								const Spacer(),
								Padding(
									padding: const EdgeInsets.only(right: 15, top: 5),
									child: CharacterLimitIndicator(
										currentLength: _currentCharCount,
										maxLength: maxCharacters,
										size: 25,
									),
								),
							],
						),
					),
				),
			),
		);
	}
}