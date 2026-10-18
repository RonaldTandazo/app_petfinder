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
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final double horizontalPadding = isSmallPhone
        ? 8
        : isMobile
            ? 12
            : 14;

    final double outerHorizontalPadding = isSmallPhone
        ? 8
        : isMobile
            ? 12
            : 20;

    final double verticalPadding = isSmallPhone ? 4 : 8;
    final double fontSize = isSmallPhone ? 10 : isMobile ? 12 : 14;
    final double iconSize = isSmallPhone ? 20 : 24;
    final double buttonSize = isSmallPhone ? 36 : 40;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: outerHorizontalPadding,
        vertical: verticalPadding,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallPhone ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: isSmallPhone ? 6 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          style: TextStyle(fontSize: fontSize),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: isSmallPhone,
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmallPhone ? 10 : 12,
            ),
            hintText: 'Buscar por nombre, raza, color...',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.teal,
              size: iconSize,
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: isSmallPhone ? 30 : 40,
              minHeight: buttonSize,
            ),
            suffixIconConstraints: BoxConstraints(
              minHeight: buttonSize,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                        size: isSmallPhone ? 18 : 20,
                      ),
                      onPressed: _clearSearch,
                      tooltip: 'Limpiar',
                    ),
                  ),
                if (widget.onFilterTap != null)
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.tune_rounded,
                        color: Colors.teal,
                        size: iconSize,
                      ),
                      onPressed: widget.onFilterTap,
                      tooltip: 'Filtros',
                    ),
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