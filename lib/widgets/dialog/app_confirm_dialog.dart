import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Sí, Eliminar',
    this.cancelText = 'No, Cancelar',
    this.confirmColor = Colors.red,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Eliminar',
    String cancelText = 'Cancelar',
    Color confirmColor = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size screenSize = MediaQuery.sizeOf(context);

        final bool isSmallPhone = screenSize.width < 360;
        final bool isMobile = screenSize.width < 600;

        final double horizontalPadding = isSmallPhone ? 16 : 24;
        final double titleFontSize = isSmallPhone ? 18 : 20;
        final double messageFontSize = isSmallPhone ? 13 : 14;
    
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 16 : 24,
            vertical: 24,
          ),
          titlePadding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isSmallPhone ? 20 : 24,
            horizontalPadding,
            8,
          ),
          contentPadding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            8,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            isSmallPhone ? 8 : 16,
            8,
            isSmallPhone ? 8 : 16,
            isSmallPhone ? 8 : 12,
          ),
          scrollable: true,
          title: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? 400 : 480,
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: messageFontSize,
                height: 1.45,
              ),
            ),
          ),
          actions: [
            if (isSmallPhone)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      cancelText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: confirmColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      confirmText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: confirmColor,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ],
        );
      },
    );
  }
}