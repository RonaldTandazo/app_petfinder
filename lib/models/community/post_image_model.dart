class PostImageModel {
  final String? url;
  final String? path;

  const PostImageModel({this.url, this.path});

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      url: json['url'] as String?,
      path: json['path'] as String?,
    );
  }
}