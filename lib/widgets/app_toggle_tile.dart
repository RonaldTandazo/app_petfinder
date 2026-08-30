import 'package:flutter/material.dart';

class AppToggleTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color activeColor;

  const AppToggleTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.activeColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = activeColor.withValues(alpha: 0.08);
    final activeBorder = activeColor.withValues(alpha: 0.6);
    final inactiveBorder = Colors.grey.shade200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: value ? activeBg : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: value ? activeBorder : inactiveBorder,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor,
          title: Row(
            children: [
              Icon(
                icon,
                color: value ? activeColor : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: value ? activeColor : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: value ? activeColor.withValues(alpha: 0.85) : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}