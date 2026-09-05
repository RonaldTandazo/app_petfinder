// lib/models/lost_found/pet_report_model.dart

enum ReportType { lost, found }

class LostPetListModel {
  final int id;
  final String name;
  final String? race;
  final int speciesId;
  final String species;
  final String animalGenderTag;
  final String city;
  final String? eventAddress;
  final double? latitude;
  final double? longitude;
  final DateTime eventDate;
  final String reportStatusTag;
  final String reportStatus;
  final String picture;

  const LostPetListModel({
    required this.id,
    required this.name,
    this.race,
    required this.speciesId,
    required this.species,
    required this.animalGenderTag,
    required this.city,
    this.eventAddress,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.reportStatusTag,
    required this.reportStatus,
    required this.picture
  });

  factory LostPetListModel.fromJson(Map<String, dynamic> json) {
    return LostPetListModel(
      id: json['id'] as int,
      name: json['name'] as String,
      race: (json['race'] ?? '') as String,
      speciesId: json['species_id'] as int,
      species: json['species'] as String,
      animalGenderTag: json['gender_tag'] as String,
      city: json['city'] as String,
      eventAddress: (json['event_address'] ?? '') as String,
      longitude: (json['longitude'] ?? 0.00) as double,
      latitude: (json['latitude'] ?? 0.00) as double,
      eventDate: json['event_date'] is DateTime ? json['event_date'] as DateTime : DateTime.parse(json['event_date'] as String),
      reportStatusTag: json['report_status_tag'] as String,
      reportStatus: json['report_status'] as String,
      picture: json['picture'] as String
    );
  }
}