import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, information }
enum SnackBarPosition { top, bottom }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    SnackBarType type = SnackBarType.information,
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);

    final (Color bgColor, IconData iconData) = switch (type) {
      SnackBarType.success => (Colors.teal.shade700, Icons.check_circle_rounded),
      SnackBarType.error => (Colors.red.shade700, Icons.cancel_rounded),
      SnackBarType.warning => (Colors.amber.shade900, Icons.warning_rounded),
      SnackBarType.information => (Colors.blue.shade800, Icons.info_rounded),
    };

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _SnackBarAnimatedWidget(
          position: position,
          duration: duration,
          onDismiss: () => overlayEntry.remove(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                children: [
                  Icon(iconData, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (description != null && description.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
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
      },
    );

    overlayState.insert(overlayEntry);
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
    final isTop = widget.position == SnackBarPosition.top;
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: isTop ? mediaQuery.padding.top + 16 : null,
      bottom: !isTop ? mediaQuery.padding.bottom + 16 : null,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          offset: _isVisible
              ? Offset.zero
              : (isTop ? const Offset(0, -0.5) : const Offset(0, 0.5)),
          child: widget.child,
        ),
      ),
    );
  }
}