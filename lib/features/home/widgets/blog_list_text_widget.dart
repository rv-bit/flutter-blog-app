import 'package:flutter/material.dart';

import 'package:flutter_blog_app/config/theme_pallet.dart';

class BlogListItem extends StatefulWidget {
	final String content;

	final Widget avatarWidget;

	final String username;
	final String time;

	final int collapsedMaxLines;	

	final Function(BuildContext) onActionPressed;

	final bool isSelectionMode;
	final bool isSelected;
	final VoidCallback? onSelectionToggle;

	const BlogListItem({
		super.key,
		
		required this.content,
		required this.onActionPressed,

		required this.avatarWidget,
		required this.username,
		required this.time,

		this.isSelectionMode = false,
		this.isSelected = false,
		this.onSelectionToggle,

		this.collapsedMaxLines = 1,
	});

	@override
	State<BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<BlogListItem> with TickerProviderStateMixin {
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
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					if (widget.isSelectionMode)
						Padding(
							padding: const EdgeInsets.only(top: 2),
							child: SizedBox(
								width: 40,
								height: 40,
								child: Checkbox(
									value: widget.isSelected,
									onChanged: (_) => widget.onSelectionToggle?.call(),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(4),
									),
								),
							),
						)
					else
						widget.avatarWidget,

					const SizedBox(width: 10),

					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisSize: MainAxisSize.min, // to shrink-wrap content
							children: [
								Row(
									crossAxisAlignment: CrossAxisAlignment.center,
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Expanded(
											child: Row(
												children: [
													Flexible(
														child: Text(
															widget.username,
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
															style: textStyle.copyWith(fontWeight: FontWeight.bold),
														),
													),
													const SizedBox(width: 6),
													Text(
														widget.time,
														style: textStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
													),
												],
											),
										),

										// Right: menu icon
										if (!widget.isSelectionMode)
											SizedBox(
												width: 36,
												height: 20,
												child: InkWell(
													onTap: () => widget.onActionPressed(context),
													borderRadius: BorderRadius.circular(20),
													child: Icon(
														Icons.more_horiz,
														size: 20,
														color: Colors.grey[600],
													),
												),
											),
									],
								),

								GestureDetector(
									onTap: widget.isSelectionMode 
										? _handleTap 
										: (_showMoreNeeded ? () => setState(() => _expanded = !_expanded) : null),
									child: SizedBox(
										child: Text(
											widget.content,
											maxLines: _expanded ? null : widget.collapsedMaxLines,
											softWrap: true,
											overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
										),
									),
								),

								if (_showMoreNeeded && !widget.isSelectionMode)
									GestureDetector(
										onTap: () => setState(() => _expanded = !_expanded),
										child: Text(
											_expanded ? 'Show less' : 'Show More',
											style: textStyle.copyWith(
												fontSize: 11,
												fontWeight: FontWeight.w500,
												color: Palette.blueColor.withAlpha(180),
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