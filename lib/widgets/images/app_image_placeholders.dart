import 'package:flutter/material.dart';

/// Hub centralizado para los placeholders de imágenes en la aplicación.
class AppImagePlaceholders {
  AppImagePlaceholders._();

  /// Variant Card: Utilizada en Cards pequeñas, Grids o vistas claras.
  static Widget card({
    required IconData icon,
    required String message,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final bool isSmall = width < 140 || height < 110;
        final bool isCompact = width < 180 || height < 140;

        final double iconSize = isSmall
            ? 20
            : isCompact
                ? 24
                : 26;

        final double fontSize = isSmall ? 8 : 10;
        final double padding = isSmall ? 4 : 8;
        final double spacing = isSmall ? 2 : 4;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade100,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: spacing),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  /// Variant Swipe: Utilizada en Cards grandes estilo Tinder/Swipe o fondos oscuros.
  static Widget swipe({
    required IconData icon,
    required String message,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final bool isCompact = width < 280 || height < 240;

        final double iconSize = isCompact ? 36 : 48;
        final double fontSize = isCompact ? 12 : 14;
        final double padding = isCompact ? 10 : 20;
        final double spacing = isCompact ? 6 : 10;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade900,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Colors.white54,
              ),
              SizedBox(height: spacing),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}