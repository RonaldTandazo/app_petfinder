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
    final String tag = newsType.tag.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.newspaper_rounded, size: fontSize + 2, color: Colors.teal.shade600),
          const SizedBox(width: 4),
          Text(
            tag,
            style: TextStyle(
              color: Colors.teal.shade700,
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