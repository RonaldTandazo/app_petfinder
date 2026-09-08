class CountryModel {
  final int id;
  final String name;
  final String abbreviation;

  const CountryModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
    );
  }
}