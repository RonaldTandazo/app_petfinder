class AdoptionPetListModel {
  final int id;
  final String name;
  final int speciesId;
  final String species;
  final String? race;
  final String genderTag;
  final String size;
  final String age;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isUrgent;
  final String picture;

  AdoptionPetListModel({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.species,
    this.race,
    required this.genderTag,
    required this.size,
    required this.age,
    required this.city,
    this.latitude,
    this.longitude,
    required this.isUrgent,
    required this.picture
  });

  factory AdoptionPetListModel.fromJson(Map<String, dynamic> json) {
    return AdoptionPetListModel(
      id: json['id'] as int,
      name: json['name'] as String,
      speciesId: json['species_id'] as int,
      species: json['species'] as String,
      race: (json['race'] ?? '') as String,
      genderTag: json['gender_tag'] as String,
      size: json['size'] as String,
      age: json['age'] as String,
      city: json['city'] as String,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      isUrgent: json['is_urgent'] as bool,
      picture: json['picture'] as String,
    );
  }
}