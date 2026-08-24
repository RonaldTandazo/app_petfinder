// 1. Modelo Base Abstracto
abstract class CatalogItemModel {
  final int id;
  final String name;
  final String tag;

  const CatalogItemModel({
    required this.id,
    required this.name,
    required this.tag,
  });
}