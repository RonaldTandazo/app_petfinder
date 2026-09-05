import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/core/router/account/account_routes.dart';
import 'package:app_petfinder/core/router/community/community_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AuthRoutes.checkAuth,
  routes: [
    ...AuthRoutes.getRoutes(),
    MainRoutes.getRoutes(),
    ...AdoptionRoutes.getRoutes(),
    ...LostPetRoutes.getRoutes(),
    ...CommunityRoutes.getRoutes(),
    ...AccountRoutes.getRoutes(),
  ],
);