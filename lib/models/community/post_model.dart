import 'package:app_petfinder/models/community/community_author_model.dart';
import 'package:app_petfinder/models/catalog/news_type_model.dart';
import 'package:app_petfinder/models/community/post_image_model.dart';

class PostModel {
  final String id;
  final CommunityAuthorModel author;
  final NewsTypeModel newsType;
  final String title;
  final String content;
  final List<PostImageModel> images;
  final int reactionsCount;
  final int commentsCount;
  final bool reactedByMe;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.author,
    required this.newsType,
    required this.title,
    required this.content,
    required this.images,
    required this.reactionsCount,
    required this.commentsCount,
    required this.reactedByMe,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      author: CommunityAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      newsType: NewsTypeModel.fromJson(json['news_type'] as Map<String, dynamic>),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      images: (json['images'] as List?)
              ?.map((e) => PostImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reactionsCount: json['reactions_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      reactedByMe: json['reacted_by_me'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String? get mainImageUrl => images.isEmpty ? null : images.first.url;

  bool isOwn(CommunityAuthorModel? me) {
    return me != null && author.tutorId == me.tutorId;
  }

  PostModel copyWith({
    int? reactionsCount,
    int? commentsCount,
    bool? reactedByMe,
  }) {
    return PostModel(
      id: id,
      author: author,
      newsType: newsType,
      title: title,
      content: content,
      images: images,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      reactedByMe: reactedByMe ?? this.reactedByMe,
      createdAt: createdAt,
    );
  }
}