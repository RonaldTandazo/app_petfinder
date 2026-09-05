class SightReportModel {
  final int id;
  final int tutorId;
  final DateTime eventDate;
  final String eventAddress;
  final double? latitude;
  final double? longitude;
  final String? comment;
  final List<String> pictures;

  const SightReportModel({
    required this.id,
    required this.tutorId,
    required this.eventDate,
    required this.eventAddress,
    this.comment,
    this.latitude,
    this.longitude,
    required this.pictures
  });

  factory SightReportModel.fromJson(Map<String, dynamic> json) {
    return SightReportModel(
      id: json['id'] as int,
      tutorId: json['tutor_id'] as int,
      eventDate: json['event_date'] is DateTime ? json['event_date'] as DateTime : DateTime.parse(json['event_date'] as String),
      eventAddress: json['event_address'] as String,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      comment: (json['comment'] ?? '') as String,
      pictures: List<String>.from(json['pictures'] ?? []),
    );
  }
}