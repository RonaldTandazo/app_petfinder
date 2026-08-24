import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class SizeModel extends CatalogItemModel {
  const SizeModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }
}