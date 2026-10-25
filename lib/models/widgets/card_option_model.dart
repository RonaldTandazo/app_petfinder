import 'package:app_petfinder/enums/card/card_option_type.dart';
import 'package:flutter/material.dart';

class CardOptionModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final CardOptionType type;
  final VoidCallback onTap;

  const CardOptionModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.type = CardOptionType.normal,
    required this.onTap,
  });
}