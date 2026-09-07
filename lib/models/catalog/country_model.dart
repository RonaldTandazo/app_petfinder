import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class CountryModel extends CatalogItemModel {
  const CountryModel({
    required super.id,
    required super.name,
    required super.tag
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['abbreviation'] as String,
    );
  }
}