import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final IconData titleIcon;
  final Color titleIconColor;
  final String title;
  final String message;
  final bool showCancel;
  final String cancelText;
  final Color cancelColor;
  final bool showConfirm;
  final String confirmText;
  final Color confirmColor;

  const AppConfirmDialog({
    super.key,
    this.titleIcon = Icons.warning_outlined,
    this.titleIconColor = Colors.red,
    required this.title,
    required this.message,
    this.showCancel = true,
    this.cancelText = 'No, Cancelar',
    this.cancelColor = Colors.teal,
    this.showConfirm = true,
    this.confirmText = 'Sí, Eliminar',
    this.confirmColor = Colors.red
  });

  static Future<bool?> show({
    required BuildContext context,
    IconData titleIcon = Icons.warning_outlined,
    Color titleIconColor = Colors.red,
    required String title,
    required String message,
    bool showCancel = true,
    String cancelText = 'No, Cancelar',
    Color cancelColor = Colors.teal,
    bool showConfirm = true,
    String confirmText = 'Sí, Eliminar',
    Color confirmColor = Colors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        titleIcon: titleIcon,
        titleIconColor: titleIconColor,
        title: title,
        message: message,
        showCancel: showCancel,
        cancelText: cancelText,
        cancelColor: cancelColor,
        showConfirm: showConfirm,
        confirmText: confirmText,
        confirmColor: confirmColor
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required Color color, required String text, required bool value}){
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: value
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () => Navigator.of(context).pop(value),
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: colors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () => Navigator.of(context).pop(value),
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
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
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: softenColor(titleIconColor),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  titleIcon,
                  size: 25,
                  color: titleIconColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                  if(showCancel)
                    _buildActionButton(context, color: cancelColor, text: cancelText, value: false),
                  if(showConfirm)
                    _buildActionButton(context, color: confirmColor, text: confirmText, value: true)
                ],
              )
            else ...[
              if(showCancel)
                _buildActionButton(context, color: cancelColor, text: cancelText, value: false),
              if(showConfirm)
                _buildActionButton(context, color: confirmColor, text: confirmText, value: true)
            ],
          ],
        );
      },
    );
  }
}