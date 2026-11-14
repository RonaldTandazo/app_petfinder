class AdoptionPetListModel {
  final int id;
  final String name;
  final String? race;
  final int speciesId;
  final String species;
  final String genderTag;
  final String size;
  final String age;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isUrgent;
  final String status;
  final String statusTag;
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
    required this.status,
    required this.statusTag,
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
      status: json['status'] as String,
      statusTag: json['status_tag'] as String,
      picture: json['picture'] as String,
    );
  }

  AdoptionPetListModel copyWith({
    int? id,
    String? name,
    String? race,
    int? speciesId,
    String? species,
    String? genderTag,
    String? size,
    String? age,
    String? city,
    double? latitude,
    double? longitude,
    bool? isUrgent,
    String? status,
    String? statusTag,
    String? picture,
  }) {
    return AdoptionPetListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      speciesId: speciesId ?? this.speciesId,
      species: species ?? this.species,
      genderTag: genderTag ?? this.genderTag,
      size: size ?? this.size,
      age: age ?? this.age,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      statusTag: statusTag ?? this.statusTag,
      picture: picture ?? this.picture,
    );
  }
}