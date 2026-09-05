import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';

class QuickActionBottomSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              '¿Qué deseas publicar?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.pets, color: Colors.white),
              ),
              title: const Text('Dar en Adopción'),
              subtitle: const Text('Publica una mascota que busca hogar'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(modalContext).pop();
                
                context.push(AdoptionRoutes.publish);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.warning_amber_rounded, color: Colors.white),
              ),
              title: const Text('Reportar Mascota Perdida'),
              subtitle: const Text('Avisa a la comunidad sobre un animal extraviado'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(modalContext).pop();

                context.push(LostPetRoutes.publish);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}