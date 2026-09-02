class CountrySummaryModel {
  final int id;
  final String name;
  final String abbreviation;

  const CountrySummaryModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory CountrySummaryModel.fromJson(Map<String, dynamic> json) {
    return CountrySummaryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      abbreviation: json['abbreviation'] as String? ?? '',
    );
  }
}