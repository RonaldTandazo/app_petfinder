class CommunityAuthorModel {
  final int tutorId;
  final String tutorType;
  final int? accountId;
  final String displayName;
  final String? avatar;

  const CommunityAuthorModel({
    required this.tutorId,
    required this.tutorType,
    this.accountId,
    required this.displayName,
    this.avatar,
  });

  factory CommunityAuthorModel.fromJson(Map<String, dynamic> json) {
    return CommunityAuthorModel(
      tutorId: json['tutor_id'] as int,
      tutorType: json['tutor_type'] as String? ?? 'user',
      accountId: json['account_id'] as int?,
      displayName: json['display_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  bool get isShelter => tutorType == 'shelter';
}