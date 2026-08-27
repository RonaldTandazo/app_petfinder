import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/pet/pet_routes.dart';
import 'package:app_petfinder/features/layout/screens/main_layout_screen.dart';
import 'package:app_petfinder/features/adoption/screens/adoption_home_screen.dart';

class MainRoutes {
  static const String prefix = '/main';

  static const String home = '$prefix/home';
  static const String lostPets = '$prefix/lost-pets';
  static const String community = '$prefix/community';
  static const String profile = '$prefix/profile';

  static RouteBase getRoutes() {
    return ShellRoute(
      builder: (context, state, child) {
        return MainLayoutScreen(child: child);
      },
      routes: [
        GoRoute(
          path: home,
          builder: (context, state) => const AdoptionHomeScreen(),
        ),
        GoRoute(
          path: lostPets,
          builder: (context, state) => const Center(child: Text('🚨 Mascotas Perdidas')),
        ),
        GoRoute(
          path: community,
          builder: (context, state) => const Center(child: Text('🌐 Comunidad')),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const Center(child: Text('👤 Perfil')),
        ),
        ...PetRoutes.getRoutes()
      ],
    );
  }
}