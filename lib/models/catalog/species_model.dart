import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class SpeciesModel extends CatalogItemModel {
  const SpeciesModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> json) {
    return SpeciesModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String,
    );
  }
}