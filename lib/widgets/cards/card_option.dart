import 'package:app_petfinder/models/widgets/card_option_color_model.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/card/card_option_type.dart';

class CardOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool compact;
  final CardOptionType type;

  const CardOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.compact = false,
    this.type = CardOptionType.normal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: compact,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: compact ? 4 : 10,
        ),
        leading: CircleAvatar(
          radius: compact ? 20 : 24,
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          child: Icon(
            icon,
            size: compact ? 20 : 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.title,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.35,
              color: colors.subtitle,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.foreground,
        ),
        onTap: onTap,
      ),
    );
  }

  CardOptionColor _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (type) {
      case CardOptionType.normal:
        return CardOptionColor(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          title: null,
          subtitle: null,
        );

      case CardOptionType.warning:
        return CardOptionColor(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          title: null,
          subtitle: null,
        );

      case CardOptionType.danger:
        return CardOptionColor(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          title: colorScheme.error,
          subtitle: null,
        );
    }
  }
}