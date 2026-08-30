class AdoptionPetModel {
  final int id;
  final String name;
  final int speciesId;
  final String species;
  final String? race;
  final String genderTag;
  final String age;
  // final String distance;
  final bool isUrgent;
  final String? picture;

  AdoptionPetModel({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.species,
    this.race,
    required this.genderTag,
    required this.age,
    required this.isUrgent,
    this.picture
  });

  factory AdoptionPetModel.fromJson(Map<String, dynamic> json) {
    return AdoptionPetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      speciesId: json['species_id'] as int,
      species: json['species'] as String,
      race: json['race'] as String? ?? '',
      genderTag: json['gender_tag'] as String,
      age: json['age'] as String,
      isUrgent: json['is_urgent'] as bool,
      picture: json['picture'] as String? ?? '',
    );
  }
}