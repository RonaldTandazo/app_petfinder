import 'package:flutter/material.dart';

class AdoptionSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const AdoptionSearchBar({
    super.key,
    this.onChanged,
    this.onFilterTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, raza...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            icon: Icon(Icons.search, color: Colors.teal),
            suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.teal),
                  onPressed: onFilterTap,
                  tooltip: 'Filtros',
                )
              : null,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}