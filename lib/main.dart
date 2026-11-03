import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_petfinder/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_petfinder/core/storage/session_storage_service.dart';
import 'package:app_petfinder/features/connectivity/screens/connection_gate.dart';
import 'package:app_petfinder/core/theme/theme_controller.dart';
import 'package:app_petfinder/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionStorageService.loadSession();

  final ThemeController themeController = ThemeController();
  await themeController.loadThemePreference();

  runApp(
    ChangeNotifierProvider.value(
      value: themeController,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp.router(
          title: 'PetFinder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
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
          builder: (context, child) {
            return ConnectionGate(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      }
    );
  }
}