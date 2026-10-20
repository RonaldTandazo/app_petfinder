
import 'package:flutter/material.dart';

class NoConnectionScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionScreen({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isSmallPhone = width < 360;
            final isTablet = width >= 600;

            final horizontalPadding = isTablet ? 40.0 : 24.0;
            final iconSize = isSmallPhone
                ? 64.0
                : isTablet
                    ? 104.0
                    : 88.0;

            final spacing = height < 500 ? 16.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 480,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: iconSize,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: spacing),
                        Text(
                          'Sin conexión a Internet',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: isSmallPhone ? 22 : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: spacing / 2),
                        Text(
                          'Para utilizar PetFinder, necesitas conectarte '
                          'a Internet. Activa tus datos móviles o '
                          'conéctate a una red Wi-Fi.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: spacing),
                        SizedBox(
                          width: isTablet
                              ? 280
                              : double.infinity,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Reintentar conexión',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}