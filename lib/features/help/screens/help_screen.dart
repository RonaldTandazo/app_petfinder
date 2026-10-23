
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/legal/legal_routes.dart';
import 'package:app_petfinder/core/router/help/help_routes.dart';
import 'package:app_petfinder/features/help/widgets/help_option.dart';
import 'package:app_petfinder/models/help/help_option_model.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayuda y Soporte',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isSmallPhone = width < 360;
            final bool isTablet = width >= 600;

            final double horizontalPadding = isSmallPhone
                ? 12
                : isTablet
                    ? 32
                    : 20;

            final double contentMaxWidth = isTablet ? 900 : 600;
            final double headerIconSize = isSmallPhone ? 48 : 64;

            final double spacing = isSmallPhone ? 12 : 16;

            final List<HelpOptionData> options = [
              HelpOptionData(
                icon: Icons.description_outlined,
                title: 'Términos y Condiciones',
                subtitle: 'Consulta las condiciones de uso de PetFinder',
                onTap: () => context.push(LegalRoutes.terms),
              ),
              HelpOptionData(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidad',
                subtitle: 'Conoce cómo se gestionan tus datos personales',
                onTap: () => context.push(LegalRoutes.privacy),
              ),
              HelpOptionData(
                icon: Icons.bug_report_outlined,
                title: 'Centro de Ayuda',
                subtitle: 'Reporta errores o problemas con la aplicación',
                onTap: () => context.push(HelpRoutes.support),
              ),
              HelpOptionData(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Comentarios y Sugerencias',
                subtitle: 'Comparte ideas para mejorar PetFinder',
                onTap: () => context.push(HelpRoutes.feedback),
              ),
            ];

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isSmallPhone ? 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: headerIconSize,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: spacing),
                      Text(
                        '¿Cómo podemos ayudarte?',
                        textAlign: TextAlign.center,
                        style: (isSmallPhone
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 48 : 4,
                        ),
                        child: Text(
                          'Consulta nuestros documentos legales, '
                          'reporta problemas o comparte tus ideas '
                          'para mejorar PetFinder',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                            fontSize: isSmallPhone ? 13 : null,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallPhone ? 20 : 28),
                      if (isTablet)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: options.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 120,
                          ),
                          itemBuilder: (context, index) {
                            final HelpOptionData option = options[index];

                            return HelpOption(
                              icon: option.icon,
                              title: option.title,
                              subtitle: option.subtitle,
                              onTap: option.onTap,
                              compact: false,
                            );
                          },
                        )
                      else
                        ...options.map(
                          (option) => HelpOption(
                            icon: option.icon,
                            title: option.title,
                            subtitle: option.subtitle,
                            onTap: option.onTap,
                            compact: isSmallPhone,
                          ),
                        ),
                    ],
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