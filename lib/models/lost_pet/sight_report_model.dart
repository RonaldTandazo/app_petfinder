class SightReportModel {
  final int id;
  final String dateText;
  final String address;
  final String? comment;
  final double latitude;
  final double longitude;

  const SightReportModel({
    required this.id,
    required this.dateText,
    required this.address,
    this.comment,
    required this.latitude,
    required this.longitude,
  });
}