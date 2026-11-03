import 'package:flutter/material.dart';
import 'package:app_petfinder/core/helpers/color_helper.dart';
import 'package:app_petfinder/enums/status/status_type.dart';

class AppConfirmDialog extends StatelessWidget {
  final IconData? titleIcon;
  final String title;
  final String message;
  final bool showCancel;
  final String cancelText;
  final bool showConfirm;
  final String confirmText;
  final StatusType type;

  const AppConfirmDialog({
    super.key,
    this.titleIcon,
    required this.title,
    required this.message,
    this.showCancel = true,
    this.cancelText = 'No, Cancelar',
    this.showConfirm = true,
    this.confirmText = 'Sí, Eliminar',
    this.type = StatusType.error,
  });

  static Future<bool?> show({
    required BuildContext context,
    IconData? titleIcon,
    required String title,
    required String message,
    bool showCancel = true,
    String cancelText = 'No, Cancelar',
    bool showConfirm = true,
    String confirmText = 'Sí, Eliminar',
    StatusType type = StatusType.error,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        titleIcon: titleIcon,
        title: title,
        message: message,
        showCancel: showCancel,
        cancelText: cancelText,
        showConfirm: showConfirm,
        confirmText: confirmText,
        type: type,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required Color color,
    required Color foregroundColor,
    required String text,
    required bool value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: value
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: foregroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: () => Navigator.of(context).pop(value),
              child: Text(text, textAlign: TextAlign.center),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: () => Navigator.of(context).pop(value),
              child: Text(text, textAlign: TextAlign.center),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final semanticColors = getSemanticColors(colorScheme, type);

    final Color confirmColor = semanticColors.background;
    final Color confirmForegroundColor = semanticColors.foreground;

    final icon = titleIcon ?? semanticColors.icon;

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
                  color: confirmColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 25,
                  color: confirmForegroundColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: messageFontSize,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          actions: [
            if (isSmallPhone)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showCancel)
                    _buildActionButton(
                      context,
                      color: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      text: cancelText,
                      value: false,
                    ),
                  if (showConfirm)
                    _buildActionButton(
                      context,
                      color: confirmColor,
                      foregroundColor: confirmForegroundColor,
                      text: confirmText,
                      value: true,
                    ),
                ],
              )
            else ...[
              if (showCancel)
                _buildActionButton(
                  context,
                  color: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  text: cancelText,
                  value: false,
                ),
              if (showConfirm)
                _buildActionButton(
                  context,
                  color: confirmColor,
                  foregroundColor: confirmForegroundColor,
                  text: confirmText,
                  value: true,
                ),
            ],
          ],
        );
      },
    );
  }
}