import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_position.dart';
import 'package:app_petfinder/core/helpers/color_helper.dart';
import 'package:app_petfinder/enums/status/status_type.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    StatusType type = StatusType.information,
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);

    final colorScheme = Theme.of(context).colorScheme;

    final semanticColors = getSemanticColors(colorScheme, type);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _SnackBarAnimatedWidget(
          position: position,
          duration: duration,
          onDismiss: () => overlayEntry.remove(),
          child: _SnackBarContent(
            title: title,
            description: description,
            bgColor: semanticColors.background,
            foregroundColor: semanticColors.foreground,
            iconData: semanticColors.icon,
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);
  }
}

class _SnackBarContent extends StatelessWidget {
  final String title;
  final String? description;
  final Color bgColor;
  final Color foregroundColor;
  final IconData iconData;

  const _SnackBarContent({
    required this.title,
    required this.description,
    required this.bgColor,
    required this.foregroundColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;

    final double horizontalMargin = isSmallPhone ? 12 : 16;
    final double horizontalPadding = isSmallPhone ? 12 : 16;
    final double verticalPadding = isSmallPhone ? 10 : 12;
    final double iconSize = isSmallPhone ? 24 : 28;
    final double titleFontSize = isSmallPhone ? 13 : 14;
    final double descriptionFontSize = isSmallPhone ? 11 : 12;

    return SafeArea(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isMobile ? 560 : 440,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                iconData,
                color: foregroundColor,
                size: iconSize,
              ),
              SizedBox(width: isSmallPhone ? 8 : 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (description != null && description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        softWrap: true,
                        style: TextStyle(
                          color: foregroundColor.withValues(alpha: 0.85),
                          fontSize: descriptionFontSize,
                          height: 1.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget interno encargado de manejar la entrada, salida y posición
class _SnackBarAnimatedWidget extends StatefulWidget {
  final Widget child;
  final SnackBarPosition position;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SnackBarAnimatedWidget({
    required this.child,
    required this.position,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SnackBarAnimatedWidget> createState() => _SnackBarAnimatedWidgetState();
}

class _SnackBarAnimatedWidgetState extends State<_SnackBarAnimatedWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Entrada en el siguiente frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });

    // Salida programada
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _isVisible = false);
        // Esperar a que concluya la animación de salida para remover del overlay
        Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
      }
    });
  }

  @override
  Widget build(BuildContext me) {
    final bool isTop = widget.position == SnackBarPosition.top;
    final Size screenSize = MediaQuery.sizeOf(context);
    final double safeTop = MediaQuery.paddingOf(context).top;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    final bool isSmallPhone = screenSize.width < 360;
    final double verticalOffset = isSmallPhone ? 12 : 16;

    return Positioned(
      top: isTop ? safeTop + verticalOffset : null,
      bottom: !isTop ? safeBottom + verticalOffset : null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isVisible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            offset: _isVisible
              ? Offset.zero
              : (isTop
                  ? const Offset(0, -0.5)
                  : const Offset(0, 0.5)),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}