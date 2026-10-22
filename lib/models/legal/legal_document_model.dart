import 'package:app_petfinder/enums/legal/legal_document_type.dart';

class LegalDocumentModel {
  final int id;
  final String name;
  final LegalDocumentType tag;
  final String version;
  final String? path;
  final DateTime publishedAt;

  LegalDocumentModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.version,
    this.path,
    required this.publishedAt
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: LegalDocumentType.fromString(json['tag'] as String?),
      version: json['version'] as String,
      path: (json['path'] ?? '') as String,
      publishedAt: json['published_at'] is DateTime ? json['published_at'] as DateTime : DateTime.parse(json['published_at'] as String),
    );
  }

  LegalDocumentModel copyWith({
    int? id,
    String? name,
    LegalDocumentType? tag,
    String? version,
    String? path,
    DateTime? publishedAt,
  }) {
    return LegalDocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      version: version ?? this.version,
      path: path ?? this.path,
      publishedAt: publishedAt ?? this.publishedAt
    );
  }
}