import 'package:flutter/material.dart';

class AdoptionSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const AdoptionSearchBar({
    super.key,
    this.onChanged,
    this.onFilterTap
  });

  @override
  State<AdoptionSearchBar> createState() => _AdoptionSearchBarState();
}

class _AdoptionSearchBarState extends State<AdoptionSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
    widget.onChanged?.call('');
  }

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
          controller: _controller,
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, raza, color...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            icon: Icon(Icons.search, color: Colors.teal),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                    onPressed: _clearSearch,
                    tooltip: 'Limpiar',
                  ),
                if (widget.onFilterTap != null)
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: Colors.teal),
                    onPressed: widget.onFilterTap,
                    tooltip: 'Filtros',
                  ),
              ],
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}