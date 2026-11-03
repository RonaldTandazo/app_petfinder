import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Colors.teal;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.blue.shade700,
      onSecondary: Colors.white,

      tertiary: Colors.amber.shade800,
      onTertiary: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.blue.shade300,
      onSecondary: Colors.black,

      tertiary: Colors.amber.shade300,
      onTertiary: Colors.black,
    ),
    brightness: Brightness.dark,
  );
}