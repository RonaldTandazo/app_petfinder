import 'package:app_petfinder/core/utils/image_url_helper.dart';
import 'package:app_petfinder/core/utils/relative_time_helper.dart';
import 'package:app_petfinder/features/community/widgets/news_type_badge.dart';
import 'package:app_petfinder/features/community/widgets/reaction_button.dart';
import 'package:app_petfinder/models/community/post_model.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isOwn;
  final VoidCallback? onTap;
  final ValueChanged<int>? onImageTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<ReactionResult> Function(bool activate) onToggleReaction;
  final ValueChanged<ReactionResult>? onReactionResult;

  const PostCard({
    super.key,
    required this.post,
    required this.onToggleReaction,
    this.isOwn = false,
    this.onTap,
    this.onImageTap,
    this.onEdit,
    this.onDelete,
    this.onReactionResult,
  });

  String get _authorTypeLabel => post.author.isShelter ? 'Refugio' : 'Usuario';

  Widget _buildAvatar() {
    final avatar = ImageUrlHelper.resolve(post.author.avatar ?? '');
    final hasAvatar = avatar.isNotEmpty;

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.teal.shade100,
      backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
      child: hasAvatar
          ? null
          : Text(
              post.author.displayName.isNotEmpty ? post.author.displayName.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                color: Colors.teal.shade700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildMainImage() {
    final imageUrl = ImageUrlHelper.resolve(post.mainImageUrl ?? '');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => AppImagePlaceholders.card(
                  icon: Icons.broken_image_outlined,
                  message: 'No se pudo obtener\nla imagen',
                ),
              )
            : AppImagePlaceholders.card(
                icon: Icons.pets,
                message: 'Sin imagen disponible',
              ),
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600, size: 20),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.author.displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '· ${formatRelativeTime(post.createdAt)}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _authorTypeLabel,
                            style: TextStyle(fontSize: 12, color: Colors.teal.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (isOwn) _buildOptionsMenu(),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onImageTap == null ? null : () => onImageTap!(0),
                child: _buildMainImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NewsTypeBadge(newsType: post.newsType),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ReactionButton(
                          reacted: post.reactedByMe,
                          count: post.reactionsCount,
                          onToggle: onToggleReaction,
                          onResult: onReactionResult,
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.mode_comment_outlined, size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(
                          '${post.commentsCount}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}