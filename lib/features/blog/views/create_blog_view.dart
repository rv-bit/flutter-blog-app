import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart' hide AppBar;

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';

import '../widgets/app_bars/general_blog_bar_widget.dart';
import '../widgets/bottom_bar_actions_widget.dart';

import '../controllers/blog_add_controller.dart';

class CreateBlogView extends ConsumerStatefulWidget {
	const CreateBlogView({super.key});

  	@override ConsumerState<ConsumerStatefulWidget> createState() => _CreateBlogViewState();
}

class _CreateBlogViewState extends ConsumerState<CreateBlogView> {
	final contentTextController = TextEditingController();
	final titleTextController = TextEditingController();

	bool _contentInField = false;
	bool _titleInField = false;

	int _currentCharCount = 0;

	List<File> images = [];

	@override
	void dispose() {
		super.dispose();
		contentTextController.dispose();
		titleTextController.dispose();
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
		final pickedImage = await common_utils.pickImageCamera();
		if (pickedImage != null) {
			setState(() {
				images.add(pickedImage);
			});
		}
	}

	void onPostBlog(bool isSubmitting) async {
		if (isSubmitting) return;

		final router = GoRouter.of(context);

		await ref.read(createBlogProvider.notifier).createBlog(
			title: titleTextController.text,
			content: contentTextController.text,
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
				controller: titleTextController,
				onControllerChanged: (val) => {
					setState(() {
						_titleInField = val.isNotEmpty;
					})
				},
				onLeadingButton: () => onHandleCloseButton(),
				onSubmit: () => onPostBlog(isSubmitting),
				trailingButtonTitle: 'Post',
				trailingButtonTitleSize: 15,
				opacity: (_contentInField && _titleInField) ? 1.0 : 0.5,
			),
			body: SafeArea(
				child: SingleChildScrollView(
					child: Column(
						children: [
							Padding(
								padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Padding(
											padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
											child: CircleAvatar(
												backgroundColor: theme.Palette.blueColor,
												radius: 15,
											),
										),

										Expanded(
											child: TextField(
												onTapOutside: (event) {
													FocusManager.instance.primaryFocus?.unfocus();
												},
												controller: contentTextController,
												onChanged: (val) => {
													setState(() {
														_currentCharCount = val.length;
														_contentInField = val.isNotEmpty;
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
														color: theme.Palette.greyColor,
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
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 5),
									child: common_widgets.imageCarousel(
										context,
										images.asMap().entries.map((entry) {
											final index = entry.key;
											final file = entry.value; 

											return common_widgets.imageTile(
												image: Image.file(
													file,
													height: 400,
													fit: BoxFit.cover,
													gaplessPlayback: true,
												),
												overlay: _removeButtonOverlay(() {
													setState(() {
														images.removeAt(index);
													});
												}),
											);
										}).toList(),
									),
								)
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

	Widget _removeButtonOverlay(VoidCallback onTap) {
		return Positioned(
			top: 8,
			right: 8,
			child: GestureDetector(
				onTap: onTap,
				child: Container(
					decoration: BoxDecoration(
						color: Colors.black.withValues(alpha: 0.6),
						shape: BoxShape.circle,
					),
					padding: const EdgeInsets.all(6),
					child: const Icon(Icons.close, size: 18, color: Colors.white),
				),
			),
		);
	}
}