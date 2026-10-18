import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppContactActionButtons extends StatelessWidget {
  final String? phoneNumber;
  final String? phoneHome;

  const AppContactActionButtons({
    super.key,
    required this.phoneNumber,
    required this.phoneHome,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoneMobile = phoneNumber != null && phoneNumber!.trim().isNotEmpty;

    final bool hasPhoneHome = phoneHome != null && phoneHome!.trim().isNotEmpty;

    if (!hasPhoneMobile && !hasPhoneHome) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallPhone = constraints.maxWidth < 360;
        final bool isMobile = constraints.maxWidth < 600;

        final double buttonHeight = isSmallPhone ? 44 : 48;
        final double iconSize = isSmallPhone ? 18 : 20;
        final double fontSize = isSmallPhone ? 12 : 14;
        final double spacing = isSmallPhone ? 8 : 10;

        final List<Widget> buttons = <Widget>[
          if (hasPhoneMobile)
            _buildButton(
              label: 'Llamar celular',
              icon: Icons.phone,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              height: buttonHeight,
              iconSize: iconSize,
              fontSize: fontSize,
              onPressed: () => _launchPhone(phoneNumber!),
            ),

          if (hasPhoneMobile)
            _buildButton(
              label: 'WhatsApp',
              icon: Icons.chat_bubble_outline,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.teal,
              height: buttonHeight,
              iconSize: iconSize,
              fontSize: fontSize,
              outlined: true,
              onPressed: () => _launchWhatsApp(phoneNumber!),
            ),

          if (hasPhoneHome)
            _buildButton(
              label: 'Llamar casa',
              icon: Icons.local_phone,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              height: buttonHeight,
              iconSize: iconSize,
              fontSize: fontSize,
              onPressed: () => _launchPhone(phoneHome!),
            ),
        ];

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                buttons[i],
                if (i < buttons.length - 1)
                  SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              Expanded(child: buttons[i]),
              if (i < buttons.length - 1)
                SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required double height,
    required double iconSize,
    required double fontSize,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    final ButtonStyle style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: BorderSide(color: foregroundColor),
            shape: shape,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: shape,
          );

    final Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        style: style,
        onPressed: onPressed,
        child: buttonChild,
      );
    }

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: buttonChild,
    );
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone.trim());

    await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (cleanPhone.isEmpty) return;

    final Uri uri = Uri.https('wa.me', '/$cleanPhone');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}