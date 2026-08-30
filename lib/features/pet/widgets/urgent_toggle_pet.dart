import 'package:flutter/material.dart';

class UrgentTogglePet extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const UrgentTogglePet({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgentColor = value ? Colors.amber.shade50 : Colors.white;
    final borderColor = value ? Colors.amber.shade600 : Colors.grey.shade200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isUrgentColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.amber.shade700,
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: value ? Colors.amber.shade800 : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Caso Urgente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: value ? Colors.amber.shade900 : Colors.black87,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Marca esta opción si la mascota requiere adopción/hogar temporal de forma prioritaria.',
              style: TextStyle(
                fontSize: 12,
                color: value
                    ? Colors.amber.shade900.withValues(alpha: 0.8)
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}