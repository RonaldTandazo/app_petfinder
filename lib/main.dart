import 'package:flutter/material.dart';
import 'package:app_petfinder/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_petfinder/core/utils/session_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionInfo.loadSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES')
      ],
      locale: const Locale('es', 'ES'),
      routerConfig: appRouter,
    );
  }
}