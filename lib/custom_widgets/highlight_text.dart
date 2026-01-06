import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? normalStyle;
  final TextStyle? highlightStyle;
  final int maxLines;
  final TextOverflow overflow;

  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    this.normalStyle,
    this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: normalStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: normalStyle,
          ),
        );
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: normalStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: highlightStyle ??
              normalStyle?.copyWith(
                backgroundColor: Colors.yellow.shade300,
                fontWeight: FontWeight.w600,
              ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(children: spans),
    );
  }
}
