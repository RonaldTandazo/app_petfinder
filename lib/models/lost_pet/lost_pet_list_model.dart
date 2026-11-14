class LostPetListModel {
  final int id;
  final String name;
  final String? race;
  final int speciesId;
  final String species;
  final String genderTag;
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
    required this.genderTag,
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
      genderTag: json['gender_tag'] as String,
      city: json['city'] as String,
      eventAddress: (json['event_address'] ?? '') as String,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      eventDate: json['event_date'] is DateTime ? json['event_date'] as DateTime : DateTime.parse(json['event_date'] as String),
      reportStatusTag: json['report_status_tag'] as String,
      reportStatus: json['report_status'] as String,
      picture: json['picture'] as String
    );
  }

  LostPetListModel copyWith({
    int? id,
    String? name,
    String? race,
    int? speciesId,
    String? species,
    String? genderTag,
    String? city,
    String? eventAddress,
    double? latitude,
    double? longitude,
    DateTime? eventDate,
    String? reportStatusTag,
    String? reportStatus,
    String? picture,
  }) {
    return LostPetListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      speciesId: speciesId ?? this.speciesId,
      species: species ?? this.species,
      genderTag: genderTag ?? this.genderTag,
      city: city ?? this.city,
      eventAddress: eventAddress ?? this.eventAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDate: eventDate ?? this.eventDate,
      reportStatusTag: reportStatusTag ?? this.reportStatusTag,
      reportStatus: reportStatus ?? this.reportStatus,
      picture: picture ?? this.picture,
    );
  }
}