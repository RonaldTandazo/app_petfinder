import 'package:flutter/material.dart';

class HelpOptionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HelpOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}