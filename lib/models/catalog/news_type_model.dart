import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class NewsTypeModel extends CatalogItemModel {
  const NewsTypeModel({required super.id, required super.name, required super.tag});

  factory NewsTypeModel.fromJson(Map<String, dynamic> json) {
    return NewsTypeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }
}