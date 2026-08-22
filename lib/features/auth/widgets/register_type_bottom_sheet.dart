import 'package:flutter/material.dart';

class RegisterTypeBottomSheet extends StatelessWidget {
  const RegisterTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '¿Cómo deseas registrarte?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('Tutor de Mascota'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth/register-user');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.orange),
            title: const Text('Refugio / Fundación'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth/register-shelter');
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}