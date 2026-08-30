import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class HealthConditionModel extends CatalogItemModel {
  const HealthConditionModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory HealthConditionModel.fromJson(Map<String, dynamic> json) {
    return HealthConditionModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      tag: (json['tag'] ?? '') as String,
    );
  }
}