import 'package:app_petfinder/models/catalog/catalog_item_model.dart';

class GenderSummaryModel extends CatalogItemModel {
  const GenderSummaryModel({required super.id, required super.name, required super.tag});

  factory GenderSummaryModel.fromJson(Map<String, dynamic> json) {
    return GenderSummaryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }
}