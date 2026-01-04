import 'package:flutter/material.dart' as m;
import 'package:flutter/rendering.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

class AppBar extends m.StatelessWidget implements m.PreferredSizeWidget {
	final m.VoidCallback onLeadingButton;
	final m.ValueChanged<String>? onControllerChanged;
	final m.VoidCallback onSubmit;
	final m.TextEditingController controller;

	final String trailingButtonTitle;
	final double trailingButtonTitleSize;
	final double opacity;

  	const AppBar({
		super.key,

		required this.controller,
		required this.onLeadingButton,
		required this.onControllerChanged,
		required this.onSubmit,
		required this.opacity,

		this.trailingButtonTitle = 'Post',
		this.trailingButtonTitleSize = 15
	});


	@override
	m.Size get preferredSize => const m.Size.fromHeight(m.kToolbarHeight);

	@override
	m.Widget build(m.BuildContext context) {
		final textStyle = m.DefaultTextStyle.of(context).style;

		final styleTitle = textStyle.copyWith(
			fontSize: 15,
			fontWeight: FontWeight.bold
		);

		return m.AppBar(
			titleSpacing: 0,
			leadingWidth: 45,
			backgroundColor: theme.Palette.backgroundColor,
			leading: m.IconButton(
				onPressed: onLeadingButton,
				icon: const m.Icon(m.Icons.close, size: 25),
			),
			title: m.Row(
				crossAxisAlignment: m.CrossAxisAlignment.center,
				mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
				children: [
					m.Expanded(
						child: m.TextField(
							onTapOutside: (event) {
								m.FocusManager.instance.primaryFocus?.unfocus();
							},
							controller: controller,
							onChanged: onControllerChanged,
							maxLength: 30,
							style: styleTitle,
							textAlignVertical: m.TextAlignVertical.top,
							decoration: m.InputDecoration(
								counterText: "", // hides the auto maxLength from TextField
								hintText: "Title",
								hintStyle: styleTitle.copyWith(
									color: theme.Palette.greyColor,
								),
								border: m.InputBorder.none,
								isDense: false,
							),
							maxLines: null,
						),
					),
					m.GestureDetector(
						onTap: onSubmit,
						child: m.Container(
							alignment: m.Alignment.centerRight,
							padding: const m.EdgeInsets.symmetric(horizontal: 10),
							child: m.Opacity(
								opacity: opacity,
								child: m.Container(
									width: 60,
									height: 30,
									alignment: m.Alignment.center,
									decoration: m.BoxDecoration(
										borderRadius: m.BorderRadius.circular(15),
										color: theme.Palette.blueColor,
									),
									child: m.Padding(
										padding: const m.EdgeInsets.only(left: 5, right: 5),
										child: m.Text(
											trailingButtonTitle,
											textAlign: m.TextAlign.center,
											style: m.TextStyle(
												fontSize: trailingButtonTitleSize,
												fontWeight: m.FontWeight.bold,
											),
										),
									) 
								)
							),
						),
					),
				],
			),
		);
	}
}