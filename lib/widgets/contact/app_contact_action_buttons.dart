import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppContactActionButtons extends StatelessWidget {
  final String? phoneNumber;

  const AppContactActionButtons({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phoneNumber != null && phoneNumber!.isNotEmpty;

    if (!hasPhone) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.phone),
            label: const Text('Llamar'),
            onPressed: () => launchUrl(Uri.parse('tel:$phoneNumber')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('WhatsApp'),
            onPressed: () {
              final cleanPhone = phoneNumber!.replaceAll(RegExp(r'\D'), '');
              launchUrl(Uri.parse('https://wa.me/$cleanPhone'));
            },
          ),
        ),
      ],
    );
  }
}