import 'package:flutter/material.dart';

IconData getGenderIcon(bool isMale) {
  return isMale ? Icons.male : Icons.female;
}

Color getGenderColor(bool isMale) {
  return isMale ? Colors.blue : Colors.pink;
}