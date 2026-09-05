class AdoptionPetModel {
  final int id;
  final String name;
  final int speciesId;
  final String species;
  final int genderId;
  final String genderTag;
  final String gender;
  final int sizeId;
  final String size;
  final DateTime bornDate;
  final String? race;
  final String? color;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phoneHome;
  final String? phoneMobile;
  final bool isUrgent;
  final String? description;
  final String petStatusTag;
  final String petStatus;
  final String age;
  final List<String> healthConditions;
  final List<String> pictures;

  AdoptionPetModel({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.species,
    required this.genderId,
    required this.genderTag,
    required this.gender,
    required this.sizeId,
    required this.size,
    required this.bornDate,
    this.race,
    this.color,
    required this.city,
    required this.address,
    this.latitude, 
    this.longitude,
    this.phoneHome,
    this.phoneMobile,
    required this.isUrgent,
    this.description,
    required this.petStatusTag,
    required this.petStatus,
    required this.age,
    required this.healthConditions,
    required this.pictures 
  });

  factory AdoptionPetModel.fromJson(Map<String, dynamic> json) {
    return AdoptionPetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      speciesId: json['species_id'] as int,
      species: json['species'] as String,
      genderId: json['gender_id'] as int,
      genderTag: json['gender_tag'] as String,
      gender: json['gender'] as String,
      sizeId: json['size_id'] as int,
      size: json['size'] as String,
      bornDate: json['born_date'] is DateTime ? json['born_date'] as DateTime : DateTime.parse(json['born_date'] as String),
      race: (json['race'] ?? '') as String,
      color: (json['color'] ?? '') as String,
      city: json['city'] as String,
      address: json['address'] as String,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      phoneHome: (json['phone_home'] ?? '') as String,
      phoneMobile: (json['phone_mobile'] ?? '') as String,
      isUrgent: json['is_urgent'] as bool,
      description: (json['description'] ?? '') as String,
      petStatusTag: json['pet_status_tag'] as String,
      petStatus: json['pet_status'] as String,
      age: json['age'] as String,
      healthConditions: List<String>.from(json['health_conditions'] ?? []),
      pictures: List<String>.from(json['pictures'] ?? []),
    );
  }
}