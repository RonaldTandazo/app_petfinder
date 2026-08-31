import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class AnimalGenderModel extends CatalogItemModel {
  const AnimalGenderModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory AnimalGenderModel.fromJson(Map<String, dynamic> json) {
    return AnimalGenderModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String,
    );
  }
}