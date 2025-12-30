import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';

class BlogListItem extends StatefulWidget {
	final String content;
	final Widget leading;
	final int collapsedMaxLines;	
	final Function(BuildContext) onActionPressed; // 🔑 Changed to accept BuildContext

	const BlogListItem({
		super.key,
		required this.content,
		required this.onActionPressed,
		required this.leading,

		this.collapsedMaxLines = 1,
	});

	@override State<BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<BlogListItem> with TickerProviderStateMixin {
	bool _expanded = false;
	bool _showMoreNeeded = false;

	@override
	Widget build(BuildContext context) {
		final textStyle = DefaultTextStyle.of(context).style;

		return Padding(
			padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					widget.leading,
					const SizedBox(width: 12),

					Expanded(
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Expanded(
									child: AnimatedSize(
										duration: const Duration(milliseconds: 250),
										curve: Curves.easeInOut,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												LayoutBuilder(
													builder: (context, constraints) {
														final textPainter = TextPainter(
															text: TextSpan(text: widget.content, style: textStyle),
															maxLines: widget.collapsedMaxLines,
															textDirection: TextDirection.ltr,
														)..layout(maxWidth: constraints.maxWidth);

														final exceeds = textPainter.didExceedMaxLines;
														
														WidgetsBinding.instance.addPostFrameCallback((_) {
															if (_showMoreNeeded != exceeds) {
																setState(() => _showMoreNeeded = exceeds);
															}
														});

														return GestureDetector(
															onTap: exceeds ? () => setState(() => _expanded = !_expanded) : null,
															child: RichText(
																text: TextSpan(
																	style: textStyle,
																	children: [
																		TextSpan(text: widget.content),
																		if (exceeds && !_expanded)
																			TextSpan(
																				text: ' Show More',
																				style: textStyle.copyWith(
																					fontSize: 11,
																					color: Palette.blueColor,
																					fontWeight: FontWeight.w500,
																				),
																			),
																		if (_expanded && exceeds)
																			TextSpan(
																				text: ' Show less',
																				style: textStyle.copyWith(
																					fontSize: 11,
																					color: Palette.blueColor,
																					fontWeight: FontWeight.w500,
																				),
																			),
																	],
																),
																maxLines: _expanded ? null : widget.collapsedMaxLines,
																overflow: _expanded ? TextOverflow.visible : TextOverflow.clip,
															),
														);
													},
												),
											],
										),
									),
								),
								
								Material(
									color: Colors.transparent,
									child: InkWell(
										onTap: () => widget.onActionPressed(context),
										borderRadius: BorderRadius.circular(20),
										child: Padding(
											padding: const EdgeInsets.all(4),
											child: Icon(
												Icons.more_horiz,
												size: 20,
												color: Colors.grey[600],
											),
										),
									),
								),
							],
						),
					),
				],
			),
		);
	}
}