import 'package:app_petfinder/models/catalog/news_type_model.dart';
import 'package:flutter/material.dart';

class NewsTypeBadge extends StatelessWidget {
  final NewsTypeModel newsType;
  final double fontSize;

  const NewsTypeBadge({
    super.key,
    required this.newsType,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String tag = newsType.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.newspaper_rounded,
            size: fontSize + 2,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            tag,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}