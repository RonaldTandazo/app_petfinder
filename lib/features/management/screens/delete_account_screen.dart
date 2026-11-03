import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/storage/storage_service.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:app_petfinder/features/management/widgets/information_item.dart';
import 'package:app_petfinder/repository/management/management_repository.dart';
import 'package:app_petfinder/widgets/dialogs/app_confirm_dialog.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';

class DeleteAccountScreen extends StatefulWidget {
  final Future<void> Function()? onDeleteAccount;

  const DeleteAccountScreen({
    super.key,
    this.onDeleteAccount,
  });

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final ManagementRepository _managementRepository = ManagementRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Eliminar Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          
          final bool isSmallPhone = width < 360;
          final bool isTablet = width >= 600;

          final double horizontalPadding = isSmallPhone
            ? 12.0
            : isTablet
                ? 32.0
                : 20.0;

          final double spacing = isSmallPhone ? 12 : 16;
          final double contentWidth = isTablet ? 680.0 : 520.0;
          final double sectionSpacing = isSmallPhone ? 20.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isSmallPhone ? 16 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme: theme, isSmallPhone: isSmallPhone),
                    SizedBox(height: sectionSpacing),
                    
                    _buildInformationCard(theme),
                    SizedBox(height: spacing),
                    
                    _buildConsequencesCard(theme),
                    SizedBox(height: spacing),
                    
                    _buildCancellationCard(theme),
                    SizedBox(height: sectionSpacing),
                    
                    _buildActions(theme),
                    SizedBox(height: spacing),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required ThemeData theme,
    required bool isSmallPhone,
  }) {
    final colorScheme = theme.colorScheme;

    final double spacing = isSmallPhone ? 12.0 : 16.0;

    return Column(
      children: [
        Container(
          width: isSmallPhone ? 76 : 92,
          height: isSmallPhone ? 76 : 92,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_off_outlined,
            size: isSmallPhone ? 38 : 46,
            color: colorScheme.onErrorContainer,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          '¿Quieres eliminar tu cuenta?',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallPhone ? 21 : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Antes de continuar, revisa qué implica eliminar '
          'tu cuenta de PetFinder y cómo se gestionará tu solicitud.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tiempo de procesamiento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'La solicitud de eliminación puede tardar hasta '
              '15 días en procesarse.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Si cambias de opinión durante este periodo, '
              'podrás volver a iniciar sesión y decidir si deseas '
              'cancelar la solicitud, siempre que aún esté pendiente.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsequencesCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Qué debes tener en cuenta?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const InformationItem(
              icon: Icons.person_outline_rounded,
              text: 'Perderás el acceso a tu cuenta de PetFinder.',
            ),
            const SizedBox(height: 14),
            const InformationItem(
              icon: Icons.pets_rounded,
              text: 'Se eliminarán las publicaciones y los datos '
                  'asociados a tu cuenta conforme al proceso '
                  'de eliminación de la aplicación.',
            ),
            const SizedBox(height: 14),
            const InformationItem(
              icon: Icons.image_outlined,
              text: 'Las fotografías y demás contenidos asociados '
                  'a tu cuenta también se verán afectados.',
            ),
            const SizedBox(height: 14),
            const InformationItem(
              icon: Icons.lock_outline_rounded,
              text: 'Una vez completada la eliminación, recuperar '
                  'la cuenta y sus datos no será posible.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.login_rounded,
            color: colorScheme.onTertiaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cambiaste de opinión?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Si ya solicitaste eliminar tu cuenta, puedes '
                  'volver a iniciar sesión mientras la solicitud '
                  'siga pendiente. La aplicación te permitirá '
                  'decidir si deseas cancelar el proceso o '
                  'mantener tu solicitud de eliminación.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Iniciar sesión no cancelará automáticamente '
                  'la solicitud. La cancelación requerirá '
                  'tu confirmación.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: () => _handleDelete(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.person_off_outlined),
            label: Text(
              'Solicitar Eliminación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onError,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),

        SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              elevation: 2,
              side: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Conservar mi cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    final bool confirmed = await _confirmDeletion();
    if (!confirmed || !mounted) return;

    AppLoadingOverlay.show(
      context,
      title: 'Ingresando Solicitud...',
      description: 'Estamos ingresando tu solicitud, por favor espera un momento',
    );

    String? deletionMessage;

    try {
      final response = await _managementRepository.deleteAccount();
      if (!mounted) return;

      if(!response.ok) return;

      StorageService.cleanSessionStorage();

      deletionMessage = response.message;
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if(mounted) AppLoadingOverlay.hide();
    }

    if(mounted && deletionMessage != null) {
      final bool close = await _deletionMessage(deletionMessage);
      if(close && mounted){
        context.go(AuthRoutes.login);
      }
    }
  }

  Future<bool> _confirmDeletion() async {
    final bool? confirm = await AppConfirmDialog.show(
      context: context,
      title: 'Eliminar Cuenta',
      message: '¿Estás seguro de que deseas solicitar la eliminación de tu cuenta? \n\nRevisa las consecuencias antes de continuar.',
    );

    return confirm ?? false;
  }

  Future<bool> _deletionMessage(String message) async {
    final bool? confirm = await AppConfirmDialog.show(
      context: context,
      title: 'Solicitud Ingresada',
      message: message,
      showCancel: false,
      confirmText: 'Aceptar',
      type: StatusType.success
    );

    return confirm ?? true;
  }
}