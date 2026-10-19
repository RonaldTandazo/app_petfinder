import 'package:app_petfinder/enums/followed/followed_pet_type.dart';
import 'package:flutter/material.dart';

class FollowedPetModel {
  final int id;
  final String name;
  final String description;
  final String location;
  final String species;
  final String age;
  final String gender;
  final FollowedPetType type;
  final String imageUrl;

  const FollowedPetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.species,
    required this.age,
    required this.gender,
    required this.type,
    required this.imageUrl,
  });

  String get categoryLabel {
    return type == FollowedPetType.adoption
        ? 'En adopción'
        : 'Mascota perdida';
  }

  IconData get categoryIcon {
    return type == FollowedPetType.adoption
        ? Icons.home_rounded
        : Icons.search_rounded;
  }

  Color get categoryColor {
    return type == FollowedPetType.adoption
        ? const Color(0xFF16866B)
        : const Color(0xFFE58B35);
  }
}