import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';

class BlogListItem extends StatefulWidget {
	final String content;
	final Widget? leading;
	final Widget? trailing;
	final int collapsedMaxLines;

	const BlogListItem({
		super.key,
		required this.content,

		this.leading,
		this.trailing,
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
					if (widget.leading != null) widget.leading!,
					if (widget.leading != null) const SizedBox(width: 12),

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
																	text: '... ',
																	style: textStyle,
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
													overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
												),
												
											);
										},
									),

									if (widget.trailing != null) ...[
										const SizedBox(height: 6),
										widget.trailing!,
									],
								],
							),
						),
					),
				],
			),
		);
	}
}