import 'package:flutter/material.dart';

class AppLoadingOverlay {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    String title = 'Procesando...',
    String? description,
  }) {
    if (_currentEntry != null) return;

    _currentEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(
        title: title,
        description: description,
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _LoadingOverlayWidget extends StatelessWidget {
  final String title;
  final String? description;

  const _LoadingOverlayWidget({
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;
    final bool isShortScreen = screenSize.height < 500;

    final double horizontalMargin = isSmallPhone ? 20 : 32;
    final double horizontalPadding = isSmallPhone ? 18 : 24;
    final double verticalPadding = isSmallPhone ? 20 : 26;
    final double indicatorSize = isSmallPhone ? 32 : 40;
    final double titleFontSize = isSmallPhone ? 14 : 16;
    final double descriptionFontSize = isSmallPhone ? 12 : 13;
    final double spacing = isSmallPhone ? 14 : 20;

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalMargin,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? 400 : 440,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isShortScreen ? 16 : verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: indicatorSize,
                        height: indicatorSize,
                        child: const CircularProgressIndicator(
                          color: Colors.teal,
                          strokeWidth: 3.5,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      if (description != null &&
                          description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}