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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _buildTile(item)).toList(),
      ),
    );
  }

  Widget _buildTile(QuickInfoItem item) {
    return Column(
      children: [
        Icon(item.icon, size: 20, color: Colors.teal),
        const SizedBox(height: 4),
        Text(item.label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(item.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}