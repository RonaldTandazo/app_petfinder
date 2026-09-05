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
    final bool hasPhoneMobile = phoneNumber != null && phoneNumber!.isNotEmpty;
    final bool hasPhoneHome = phoneHome != null && phoneHome!.isNotEmpty;

    if (!hasPhoneMobile && !hasPhoneHome) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        final buttons = <Widget>[
          if (hasPhoneMobile)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.phone),
                label: const Text('Llamar Celular'),
                onPressed: () {
                  launchUrl(
                    Uri.parse('tel:$phoneNumber'),
                  );
                },
              ),
            ),

          if (hasPhoneMobile)
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('WhatsApp'),
                onPressed: () {
                  final cleanPhone =
                      phoneNumber!.replaceAll(RegExp(r'\D'), '');

                  launchUrl(
                    Uri.parse('https://wa.me/$cleanPhone'),
                  );
                },
              ),
            ),

          if (hasPhoneHome)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.local_phone),
                label: const Text('Llamar Casa'),
                onPressed: () {
                  launchUrl(
                    Uri.parse('tel:$phoneHome'),
                  );
                },
              ),
            ),
        ];

        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                // Quitamos Expanded porque estamos en Column.
                SizedBox(
                  width: double.infinity,
                  child: buttons[i] is Expanded
                      ? (buttons[i] as Expanded).child
                      : buttons[i],
                ),
                if (i < buttons.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              Expanded(
                child: buttons[i] is Expanded
                    ? (buttons[i] as Expanded).child
                    : buttons[i],
              ),
              if (i < buttons.length - 1)
                const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}