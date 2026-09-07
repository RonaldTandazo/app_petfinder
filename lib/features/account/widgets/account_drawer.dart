import 'package:flutter/material.dart';

class AccountDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String? avatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSecurity;
  final VoidCallback? onHelp;
  final VoidCallback? onLogout;

  const AccountDrawer({
    super.key,
    required this.name,
    required this.email,
    this.avatar,
    this.onProfileTap,
    this.onEditProfile,
    this.onSecurity,
    this.onHelp,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isSmallScreen = screenWidth < 600;

    final double drawerWidth = isSmallScreen ? screenWidth : 360.0;

    return Drawer(
      width: drawerWidth,
      child: Column(
        children: [
          Material(
            color: colorScheme.primary,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                onProfileTap?.call();
              },
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: colorScheme.surface,
                          backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
                          child: avatar == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 30,
                                color: colorScheme.primary,
                              )
                            : null,
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Editar Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    onEditProfile?.call();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Seguridad y contraseña'),
                  onTap: () {
                    Navigator.pop(context);
                    onSecurity?.call();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Ayuda y soporte'),
                  onTap: () {
                    Navigator.pop(context);
                    onHelp?.call();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}