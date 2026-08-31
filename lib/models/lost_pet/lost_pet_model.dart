// lib/models/lost_found/pet_report_model.dart

enum ReportType { lost, found }

class LostPetModel {
  final int id;
  final String name;
  final String? race;
  final String? color;
  final String? description;
  final String? phoneHome;
  final String? phoneMobile;
  final String reportTypeTag;
  final String reportType;
  final String speciesTag;
  final String species;
  final String animalGenderTag;
  final String animalGender;
  final String sizeTag;
  final String size;
  final bool hasReward;
  final double? rewardAmount;
  final String city;
  final String? eventAddress;
  final double? latitude;
  final double? longitude;
  final String eventDate;
  final String reportStatusTag;
  final String reportStatus;
  final String? closingDate;
  final List<String> pictures;

  const LostPetModel({
    required this.id,
    required this.name,
    this.race,
    this.color,
    this.description,
    this.phoneHome,
    this.phoneMobile,
    required this.reportTypeTag,
    required this.reportType,
    required this.speciesTag,
    required this.species,
    required this.animalGenderTag,
    required this.animalGender,
    required this.sizeTag,
    required this.size,
    required this.hasReward,
    this.rewardAmount,
    required this.city,
    this.eventAddress,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.reportStatusTag,
    required this.reportStatus,
    this.closingDate,
    required this.pictures
  });

  factory LostPetModel.fromJson(Map<String, dynamic> json) {
    return LostPetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      race: (json['race'] ?? '') as String,
      color: (json['color'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      phoneHome: (json['phone_home'] ?? '') as String,
      phoneMobile: (json['phone_mobile'] ?? '') as String,
      reportTypeTag: json['report_type_tag'] as String,
      reportType: json['report_type'] as String,
      speciesTag: json['species_tag'] as String,
      species: json['species'] as String,
      animalGenderTag: json['gender_tag'] as String,
      animalGender: json['gender'] as String,
      sizeTag: json['size_tag'] as String,
      size: json['size'] as String,
      hasReward: json['has_reward'] as bool,
      rewardAmount: (json['reward_amount'] ?? 0.00) as double,
      city: json['city'] as String,
      eventAddress: (json['event_address'] ?? '') as String,
      longitude: json['longitude'] as double?,
      latitude: json['latitude'] as double?,
      eventDate: json['event_date'] as String,
      reportStatusTag: json['report_status_tag'] as String,
      reportStatus: json['report_status'] as String,
      closingDate: (json['closing_date'] ?? '') as String,
      pictures: (json['pictures'] ?? []) as List<String>
    );
  }
}