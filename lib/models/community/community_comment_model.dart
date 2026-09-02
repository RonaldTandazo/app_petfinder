import 'package:app_petfinder/models/community/community_author_model.dart';

class CommentParentModel {
  final int? tutorId;
  final String? displayName;

  const CommentParentModel({this.tutorId, this.displayName});

  factory CommentParentModel.fromJson(Map<String, dynamic> json) {
    return CommentParentModel(
      tutorId: json['tutor_id'] as int?,
      displayName: json['display_name'] as String?,
    );
  }
}

class CommunityCommentModel {
  final String id;
  final CommunityAuthorModel author;
  final String content;
  final String? parentId;
  final CommentParentModel? parent;
  final int repliesCount;
  final DateTime createdAt;

  CommunityCommentModel({
    required this.id,
    required this.author,
    required this.content,
    this.parentId,
    this.parent,
    this.repliesCount = 0,
    required this.createdAt,
  });

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    final parentJson = json['parent'] as Map<String, dynamic>?;

    return CommunityCommentModel(
      id: json['id'] as String,
      author: CommunityAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      parent: parentJson == null ? null : CommentParentModel.fromJson(parentJson),
      repliesCount: json['replies_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String? get parentName => parent?.displayName;

  bool isOwn(CommunityAuthorModel? me) {
    return me != null && author.tutorId == me.tutorId;
  }

  CommunityCommentModel copyWith({
    String? content,
    int? repliesCount,
  }) {
    return CommunityCommentModel(
      id: id,
      author: author,
      content: content ?? this.content,
      parentId: parentId,
      parent: parent,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt,
    );
  }
}