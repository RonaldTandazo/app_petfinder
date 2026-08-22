// lib/routes/auth_routes.dart
import 'package:app_petfinder/features/auth/screens/login/login_screen.dart';
import 'package:app_petfinder/features/auth/screens/register/register_shelter.dart';
import 'package:app_petfinder/features/auth/screens/register/register_user.dart';
import 'package:flutter/material.dart';

class AuthRoutes {
  static const String _prefix = '/auth';

  static const String login = '$_prefix/login';
  static const String registerTutor = '$_prefix/register-user';
  static const String registerShelter = '$_prefix/register-shelter';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      registerTutor: (context) => const RegisterUserScreen(),
      registerShelter: (context) => const RegisterShelterScreen(),
    };
  }
}