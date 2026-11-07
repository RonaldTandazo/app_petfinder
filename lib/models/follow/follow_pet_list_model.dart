import 'package:app_petfinder/enums/account/pet_source.dart';

class FollowPetListModel {
  final int id;
  final int petId;
  final String name;
  final PetSource type;
  final double? latitude;
  final double? longitude;
  final String picture;

  FollowPetListModel({
    required this.id,
    required this.petId,
    required this.name,
    required this.type,
    this.latitude,
    this.longitude,
    required this.picture
  });

  factory FollowPetListModel.fromJson(Map<String, dynamic> json) {
    return FollowPetListModel(
      id: json['id'] as int,
      petId: json['pet_id'] as int,
      name: json['name'] as String,
      type: PetSource.fromString(json['type'] as String?),
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      picture: json['picture'] as String,
    );
  }
}