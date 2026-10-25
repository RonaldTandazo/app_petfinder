
import 'package:app_petfinder/enums/card/card_option_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/management/management_routes.dart';
import 'package:app_petfinder/models/widgets/card_option_model.dart';
import 'package:app_petfinder/widgets/cards/card_option.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuenta',
          style: TextStyle(
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
            final double width = constraints.maxWidth;

            final bool isSmallPhone = width < 360;
            final bool isTablet = width >= 600;

            final double horizontalPadding = isSmallPhone
                ? 12.0
                : isTablet
                    ? 32.0
                    : 20.0;

            final double contentMaxWidth = isTablet ? 900.0 : 600.0;
            final double headerIconSize = isSmallPhone ? 48.0 : 64.0;
            final double spacing = isSmallPhone ? 12.0 : 16.0;

            final List<CardOptionModel> options = [
              CardOptionModel(
                icon: Icons.lock_outline_rounded,
                title: 'Cambiar Contraseña',
                subtitle: 'Actualiza la contraseña de tu cuenta',
                onTap: () {
                  context.push(ManagementRoutes.changePassword);
                },
              ),
              CardOptionModel(
                icon: Icons.person_off_outlined,
                title: 'Eliminar Cuenta',
                subtitle: 'Solicita la eliminación de tu cuenta y sus datos',
                type: CardOptionType.danger,
                onTap: () {
                  context.push(ManagementRoutes.deleteAccount);
                },
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
                        Icons.manage_accounts_rounded,
                        size: headerIconSize,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'Gestiona tu cuenta',
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
                          'Administra las opciones de acceso y '
                          'gestiona tu cuenta de PetFinder',
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 120,
                          ),
                          itemBuilder: (context, index) {
                            final option = options[index];

                            return CardOption(
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
                          (option) => CardOption(
                            icon: option.icon,
                            title: option.title,
                            subtitle: option.subtitle,
                            type: option.type,
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
