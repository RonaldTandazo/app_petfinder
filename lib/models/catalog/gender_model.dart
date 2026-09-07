import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class GenderModel extends CatalogItemModel {
  const GenderModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String,
    );
  }
}