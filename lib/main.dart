import 'package:app_petfinder/routes/auth/auth_routes.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        ...AuthRoutes.getRoutes(),
      },
    );
  }
}