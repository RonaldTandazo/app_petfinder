import 'package:flutter/material.dart';

class RequirementItem extends StatelessWidget {
  final bool isMet;
  final String text;

  const RequirementItem({
    super.key,
    required this.isMet,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    final color = isMet ? Colors.teal.shade700 : Colors.grey.shade500;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}