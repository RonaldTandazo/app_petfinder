import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final scale = (screenWidth / 390.0).clamp(0.78, 1.25);

    final barHeight = (64.0 * scale).clamp(56.0, 64.0);
    final horizontalPadding = screenWidth < 360 ? 12.0 : (20.0 * scale);
    final bottomPadding = mediaQuery.padding.bottom + (16.0 * scale);
    final gapWidth = (44.0 * scale).clamp(32.0, 44.0);

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: bottomPadding,
      ),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25 * scale,
              spreadRadius: -2,
              offset: Offset(0, 10 * scale),
            ),
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.15),
              blurRadius: 16 * scale,
              spreadRadius: 1,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.20),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    index: 0,
                    scale: scale,
                  ),
                  _buildNavItem(
                    icon: Icons.search_off_rounded,
                    label: 'Perdidos',
                    index: 1,
                    scale: scale,
                  ),

                  SizedBox(width: gapWidth),

                  _buildNavItem(
                    icon: Icons.people_rounded,
                    label: 'Comunidad',
                    index: 2,
                    scale: scale,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    index: 3,
                    scale: scale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required double scale,
  }) {
    final isSelected = currentIndex == index;
    final activeColor = Colors.teal.shade700;
    final inactiveColor = Colors.grey.shade700;

    final iconSize = (20.0 * scale).clamp(18.0, 20.0);
    final fontSize = (10.0 * scale).clamp(8.5, 10.0);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(100),
        splashColor: Colors.teal.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(
            horizontal: 3.0 * scale,
            vertical: 4.0 * scale,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 4.0 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: isSelected
                ? Colors.white.withValues(alpha: 0.60)
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.2),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: iconSize,
                ),
              ),
              SizedBox(height: 2 * scale),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}