import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/status/status_type.dart';

({Color background, Color foreground, IconData icon}) getSemanticColors(ColorScheme colorScheme, StatusType type) {
  switch (type) {
    case StatusType.success:
      return (
        background: colorScheme.primary,
        foreground: colorScheme.onPrimary,
        icon: Icons.check_circle_outline_rounded
      );

    case StatusType.information:
      return (
        background: colorScheme.secondary,
        foreground: colorScheme.onSecondary,
        icon: Icons.info_outline_rounded
      );

    case StatusType.warning:
      return (
        background: colorScheme.tertiary,
        foreground: colorScheme.onTertiary,
        icon: Icons.warning_amber_rounded
      );

    case StatusType.error:
      return (
        background: colorScheme.error,
        foreground: colorScheme.onError,
        icon: Icons.error_outline_rounded
      );
  }
}