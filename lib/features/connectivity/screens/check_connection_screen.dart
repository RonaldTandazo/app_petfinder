import 'package:flutter/material.dart';

class CheckingConnectionScreen extends StatelessWidget {
  const CheckingConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}