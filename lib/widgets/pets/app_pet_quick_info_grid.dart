import 'package:flutter/material.dart';

class QuickInfoItem {
  final IconData icon;
  final String label;
  final String value;

  const QuickInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class AppPetQuickInfoGrid extends StatelessWidget {
  final List<QuickInfoItem> items;

  const AppPetQuickInfoGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _buildTile(items[i]),
                ),
                if (i < items.length - 1)
                  Container(
                    height: 45,
                    width: 1,
                    color: Colors.grey.shade200,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(QuickInfoItem item) {
    return Column(
      children: [
        Icon(
          item.icon,
          size: 20,
          color: Colors.teal
        ),
        const SizedBox(height: 4),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}