import 'dart:convert';
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart' hide AppBar;

import 'package:flutter_blog_app/config/theme/index.dart' as theme;
import 'package:flutter_blog_app/core/utils/index.dart' as common_utils;
import 'package:flutter_blog_app/common/widgets/index.dart' as common_widgets;

import 'package:flutter_blog_app/models/index.dart' as models;

import 'package:flutter_blog_app/features/home/controllers/home_controller.dart';

import '../widgets/app_bars/general_blog_bar_widget.dart';
import '../widgets/bottom_bar_actions_widget.dart';

import '../controllers/individual_blog_controller.dart';
import '../controllers/blog_edit_controller.dart';

class EditBlogView extends ConsumerStatefulWidget {
	final String blogId;

	const EditBlogView({
		super.key, 
		required this.blogId
	});

  	@override ConsumerState<ConsumerStatefulWidget> createState() => _EditBlogViewState();
}

class _EditBlogViewState extends ConsumerState<EditBlogView> {
	final contentTextController = TextEditingController();
	final titleTextController = TextEditingController();

	bool _initialized = false;

	bool _contentInField = false;
	bool _titleInField = false;

	int _currentCharCount = 0;
	
	List<String> savedImageIds = []; // Store IDs for deletion
	List<String> savedImageData = []; // Store base64 for display

	List<File> localImages = []; // newly picked images

	@override
	void dispose() {
		super.dispose();
		contentTextController.dispose();
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
		final pickedImages = await common_utils.pickImages();
		setState(() {
			localImages.addAll(pickedImages);
		});
	}

	void onPickImageFromCamera() async {
		final pickedImage = await common_utils.pickImageCamera();
		if (pickedImage != null) {
			setState(() {
				localImages.add(pickedImage);
			});
		}
	}

	void onEditBlog(bool isSubmitting) async {
		final blog = ref.read(editBlogProvider(widget.blogId)).value;

		if (blog == null) return;
		if (isSubmitting) return;

		await ref.read(editBlogProvider(widget.blogId).notifier).updateBlog(
			models.UpdateBlogPayload(
				blogId: blog.id,
				title: titleTextController.text,
				content: contentTextController.text,
				savedImages: savedImageIds, // Pass IDs, not data
				newImages: localImages,
			),
		);

		if (!mounted) return;
		
		ref.read(homeViewProvider.notifier).refresh();

		ref.invalidate(individualBlogProvider(widget.blogId)); // force refetch individual
		
		onHandleCloseButton();
	}

	@override
	Widget build(BuildContext context) {
		ref.listen<AsyncValue<models.BlogPost?>>(
			editBlogProvider(widget.blogId),
			(previous, next) {
				next.whenOrNull(
					data: (blog) {
						if (blog == null || _initialized) return;

						contentTextController.text = blog.content;
						titleTextController.text = blog.title;

						_currentCharCount = blog.content.length;
						_contentInField = blog.content.isNotEmpty;
						_titleInField = blog.title.isNotEmpty;

						// Using the getters created in the model, easier to not have to compute more heavy logic inside this
						savedImageIds = blog.imageIds ?? [];
						savedImageData = blog.imageData ?? [];

						_initialized = true;
					},
				);
			},
		);

		final blogAsync = ref.watch(editBlogProvider(widget.blogId));
		final isSubmitting = blogAsync.isLoading;

		final allImagesCount = savedImageIds.length + localImages.length;

		final carouselItems = [
			// Existing images
			...savedImageData.asMap().entries.map((entry) {
				final index = entry.key;
				final base64 = entry.value;

				return common_widgets.imageTile(
					image: Image.memory(
						base64Decode(base64),
						height: 400,
						fit: BoxFit.cover,
						gaplessPlayback: true,
					),
					overlay: _removeButtonOverlay(() {
						setState(() {
							savedImageData.removeAt(index);
							savedImageIds.removeAt(index);
						});
					}),
				);
			}),

			...localImages.asMap().entries.map((entry) {
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
							localImages.removeAt(index);
						});
					}),
				);
			}),
		];


		return Scaffold(
			appBar: AppBar(
				controller: titleTextController,
				onControllerChanged: (val) => {
					setState(() {
						_titleInField = val.isNotEmpty;
					})
				},
				onLeadingButton: () => onHandleCloseButton(),
				onSubmit: () => onEditBlog(isSubmitting),
				trailingButtonTitle: 'Submit',
				trailingButtonTitleSize: 13,
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
							
							if (allImagesCount > 0 && carouselItems.isNotEmpty)
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 5),
									child: common_widgets.imageCarousel(context, carouselItems),
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