// lib/models/lost_found/pet_report_model.dart

enum ReportType { lost, found }

class LostPetModel {
  final String id;
  final String petName;
  final String species;
  final String breed;
  final String location;
  final String distance;
  final String date;
  final String imageUrl;
  final String description;
  final ReportType type;
  final String contactPhone;
  final String reporterName;

  const LostPetModel({
    required this.id,
    required this.petName,
    required this.species,
    required this.breed,
    required this.location,
    required this.distance,
    required this.date,
    required this.imageUrl,
    required this.description,
    required this.type,
    required this.contactPhone,
    required this.reporterName,
  });
}