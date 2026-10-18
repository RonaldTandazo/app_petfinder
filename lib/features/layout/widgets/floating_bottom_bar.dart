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
    final double screenWidth = mediaQuery.size.width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final double scale = isSmallPhone
      ? 0.78
      : isTablet
          ? 1.0
          : ((screenWidth / 390.0).clamp(0.82, 1.0));

    final double barHeight = isSmallPhone
      ? 40.0
      : isTablet
          ? 64.0
          : 50.0;

    final double horizontalPadding = isSmallPhone
      ? 10.0
      : isTablet
          ? 32.0
          : 16.0;

    final double bottomPadding = mediaQuery.padding.bottom +
      (isSmallPhone ? 10.0 : isTablet ? 20.0 : 12.0);

    final double gapWidth = isSmallPhone 
      ? 32.0 
      : isTablet 
          ? 48.0 
          : 38.0;

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
                    icon: Icons.pets,
                    label: 'Adopciones',
                    index: 0,
                    scale: scale,
                    isSmallPhone: isSmallPhone,
                    isTablet: isTablet
                  ),
                  _buildNavItem(
                    icon: Icons.search_off_rounded,
                    label: 'Perdidos',
                    index: 1,
                    scale: scale,
                    isSmallPhone: isSmallPhone,
                    isTablet: isTablet
                  ),

                  SizedBox(width: gapWidth),

                  _buildNavItem(
                    icon: Icons.people_rounded,
                    label: 'Comunidad',
                    index: 2,
                    scale: scale,
                    isSmallPhone: isSmallPhone,
                    isTablet: isTablet
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    index: 3,
                    scale: scale,
                    isSmallPhone: isSmallPhone,
                    isTablet: isTablet
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
    required bool isSmallPhone,
    required bool isTablet,
  }) {
    final isSelected = currentIndex == index;
    final activeColor = Colors.teal.shade700;
    final inactiveColor = Colors.grey.shade700;

    final double iconSize = isSmallPhone
      ? 15.0
      : isTablet
          ? 25.0
          : 20.0;

    final double fontSize = isSmallPhone
      ? 6.0
      : isTablet
          ? 13.0
          : 9.0;

    final double verticalMargin = isSmallPhone
      ? 2.0
      : isTablet
          ? 4.0
          : 3.0;

    final double verticalPadding = isSmallPhone
      ? 1.0
      : isTablet
          ? 4.0
          : 2.0;

    final double iconLabelSpacing = isSmallPhone
      ? 1.0
      : isTablet
          ? 3.0
          : 2.0;

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
            horizontal: isSmallPhone ? 2.0 : 3.0 * scale,
            vertical: verticalMargin,
          ),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
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
                scale: isSelected
                  ? (isSmallPhone ? 1.06 : 1.12)
                  : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: iconSize,
                ),
              ),
              SizedBox(height: iconLabelSpacing),
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