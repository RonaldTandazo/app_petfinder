// lib/models/lost_found/pet_report_model.dart

enum ReportType { lost, found }

class LostPetModel {
  final String id;
  final String name;
  final String? race;
  final String? color;
  final String? description;
  final String telephone;
  final String reportTypeTag;
  final String reportType;
  final String speciesTag;
  final String species;
  final String animalGenderTag;
  final String animalGender;
  final String sizeTag;
  final String size;
  final bool hasReward;
  final double? reward;
  final String city;
  final String eventAddress;
  final double? latitude;
  final double? longitude;
  final String eventDate;
  final String reportStatusTag;
  final String reportStatus;
  final String closingDate;
  final String picture;

  const LostPetModel({
    required this.id,
    required this.name,
    this.race,
    this.color,
    this.description,
    required this.telephone,
    required this.reportTypeTag,
    required this.reportType,
    required this.speciesTag,
    required this.species,
    required this.animalGenderTag,
    required this.animalGender,
    required this.sizeTag,
    required this.size,
    required this.hasReward,
    this.reward,
    required this.city,
    required this.eventAddress,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.reportStatusTag,
    required this.reportStatus,
    required this.closingDate,
    required this.picture
  });
}