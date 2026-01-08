import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme/index.dart' as theme;

class BlogListContent extends StatefulWidget {
	final String content;

	final Widget avatarWidget;

	final String username;
	final String time;

	final int collapsedMaxLines;	

	final Widget Function(BuildContext context)? onActionPressedWidget;

	final bool isSelectionMode;
	final bool isSelected;
	final VoidCallback? onSelectionToggle;

	const BlogListContent({
		super.key,
		
		required this.content,

		required this.avatarWidget,
		required this.username,
		required this.time,

		this.onActionPressedWidget,
		this.isSelectionMode = false,
		this.isSelected = false,
		this.onSelectionToggle,

		this.collapsedMaxLines = 1,
	});

	@override
	State<BlogListContent> createState() => _BlogListContentState();
}

class _BlogListContentState extends State<BlogListContent> with TickerProviderStateMixin {
	bool _expanded = false;
	bool _showMoreNeeded = false;

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();

		_checkTextOverflow();
	}

	void _checkTextOverflow() {
		final textStyle = DefaultTextStyle.of(context).style;

		final tp = TextPainter(
			text: TextSpan(text: widget.content, style: textStyle),
			maxLines: widget.collapsedMaxLines,
			textDirection: TextDirection.ltr,
			ellipsis: '...',
		);

		tp.layout(maxWidth: MediaQuery.of(context).size.width - 80); // Adjust for padding + icon width

		setState(() {
			_showMoreNeeded = tp.didExceedMaxLines;
		});
	}

	void _handleTap() {
		if (widget.isSelectionMode && widget.onSelectionToggle != null) {
			widget.onSelectionToggle?.call();
		}
	}

	@override
	Widget build(BuildContext context) {
		final textStyle = DefaultTextStyle.of(context).style;

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					if (widget.isSelectionMode)	...[
						SizedBox(
							width: 40,
							height: 40,
							child: Checkbox(
								value: widget.isSelected,
								onChanged: (_) => widget.onSelectionToggle?.call(),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(4),
								),
								fillColor: WidgetStateProperty.resolveWith((states) {
									if (states.contains(WidgetState.selected)) {
										return theme.Palette.blueColor;
									}
									return theme.Palette.whiteColor.withValues(alpha: 0.5);
								}),
							),
						)
					] else ...[
						Padding(
							padding: const EdgeInsets.only(top: 4),
							child: widget.avatarWidget,
						),
						const SizedBox(width: 10),
					],

					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Stack(
									children: [
										Padding(
											padding: const EdgeInsets.only(right: 40),
											child: Row(
												children: [
													Flexible(
														child: Text(
															widget.username,
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
															style: textStyle.copyWith(
																fontWeight: FontWeight.bold,
															),
														),
													),
													const SizedBox(width: 6),
													Text(
														widget.time,
														style: textStyle.copyWith(
															fontSize: 12,
															color: Colors.grey[600],
														),
													),
												],
											),
										),

										if (!widget.isSelectionMode && widget.onActionPressedWidget != null)
											Positioned(
												top: -6,
												right: -6,
												child: SizedBox(
													width: 36,
													height: 36,
													child: Builder(
														builder: (ctx) => widget.onActionPressedWidget!(ctx),
													),
												),
											),
									],
								),

								GestureDetector(
									onTap: widget.isSelectionMode ? _handleTap : (_showMoreNeeded ? () => setState(() => _expanded = !_expanded) : null),
									child: Text(
										widget.content,
										maxLines: _expanded ? null : widget.collapsedMaxLines,
										softWrap: true,
										overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
									),
								),

								/// SHOW MORE / LESS
								if (_showMoreNeeded && !widget.isSelectionMode)
									GestureDetector(
										onTap: () => setState(() => _expanded = !_expanded),
										child: Padding(
											padding: const EdgeInsets.only(top: 2),
											child: Text(
												_expanded ? 'Show less' : 'Show more',
												style: textStyle.copyWith(
													fontSize: 11,
													fontWeight: FontWeight.w500,
													color: theme.Palette.blueColor.withAlpha(180),
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