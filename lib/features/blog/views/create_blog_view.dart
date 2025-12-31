import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;

import 'package:flutter_blog_app/features/blog/widgets/bottom_bar_actions_widget.dart';

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';
import 'package:flutter_blog_app/features/blog/controllers/blog_add_controller.dart';

class CreateBlogView extends ConsumerStatefulWidget {
	const CreateBlogView({super.key});

  	@override ConsumerState<ConsumerStatefulWidget> createState() => _CreateBlogViewState();
}

class _CreateBlogViewState extends ConsumerState<CreateBlogView> {
	final blogTextBlockController = TextEditingController();

	bool _textInField = false;
	int _currentCharCount = 0;

	List<File> images = [];

	@override
	void dispose() {
		super.dispose();
		blogTextBlockController.dispose();
	}

	void onHandleCloseButton() {
		final router = GoRouter.of(context);

		if (router.canPop()) { // handle go back in history, only if there is any history to go back to
			router.pop();
		} else {
			router.go('/'); // Navigate to home if no previous route
		}
	}

	void onPickImages() async {
		List<File> pickedImages = await common_utils.pickImages();
		setState(() {
			images = [...images, ...pickedImages];
		});
	}

	void onPickImageFromCamera() async {
		File? pickedImage = await common_utils.pickImageCamera();
		if (pickedImage != null) {
			setState(() {
				images.add(pickedImage);
			});
		}
	}

	void onPostBlog(bool isSubmitting) async {
		if (isSubmitting) return;

		final router = GoRouter.of(context);

		if (images.isEmpty) {
			FocusManager.instance.primaryFocus?.unfocus();

			final snackBar = SnackBar(
				content: const Text('Images is a required field, please add at least one image'),
				duration: Duration(milliseconds: 5000),
			);

			// Find the ScaffoldMessenger in the widget tree
			// and use it to show a SnackBar.
			ScaffoldMessenger.of(context).showSnackBar(snackBar);
			return;
		}

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
		final isSubmitting = createState.isLoading;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Palette.backgroundColor,
				leading: IconButton(
					onPressed: () => onHandleCloseButton(),
					icon: const Icon(Icons.close, size: 25),
				),
				title: GestureDetector(
					onTap: () => onPostBlog(isSubmitting),
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
									items: images.asMap().entries.map((entry) {
										final index = entry.key;
										final file = entry.value;

										return Stack(
											children: [
												Container(
													width: MediaQuery.of(context).size.width,
													margin: const EdgeInsets.symmetric(
														horizontal: 5,
													),
													child: ClipRRect(
														borderRadius: BorderRadius.circular(8.0),
														child: Image.file(file, fit: BoxFit.cover),
													),
												),

												Positioned(
													top: 8,
													right: 8,
													child: GestureDetector(
														onTap: () {
															setState(() {
																images.removeAt(index);
															});
														},
														child: Container(
															decoration: BoxDecoration(
																color: Colors.black.withValues(alpha: 0.6),
																shape: BoxShape.circle,
															),
															padding: const EdgeInsets.all(6),
															child: const Icon(
																Icons.close,
																size: 18,
																color: Colors.white,
															),
														),
													),
												),
											],
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
			bottomNavigationBar: BottomBarActions(
				onPickImages: onPickImages, 
				onPickImageFromCamera: onPickImageFromCamera, 
				currentCharCount: _currentCharCount
			)
		);
	}
}