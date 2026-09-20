class PictureModel {
  final int id;
  final String url;
  final bool isMain;

  PictureModel({
    required this.id,
    required this.url,
    required this.isMain
  });

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      id: json['id'] as int,
      url: json['url'] as String,
      isMain: json['is_main'] as bool,
    );
  }
}