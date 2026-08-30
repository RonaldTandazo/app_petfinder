import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/core/router/pet/pet_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AuthRoutes.checkAuth,
  routes: [
    ...AuthRoutes.getRoutes(),
    MainRoutes.getRoutes(),
    ...PetRoutes.getRoutes()
  ],
);