import 'package:flutter/material.dart';

class AccountSelectionBottomSheet extends StatelessWidget {
  final ValueChanged<String> onAccountSelected;

  const AccountSelectionBottomSheet({
    super.key,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona tu perfil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('Cuenta Personal (Tutor)'),
            onTap: () {
              Navigator.pop(context);
              onAccountSelected('user');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.orange),
            title: const Text('Cuenta de Refugio'),
            onTap: () {
              Navigator.pop(context);
              onAccountSelected('shelter');
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}