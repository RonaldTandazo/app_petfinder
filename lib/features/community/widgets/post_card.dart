import 'package:app_petfinder/core/helpers/image_url_helper.dart';
import 'package:app_petfinder/core/helpers/relative_time_helper.dart';
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

  Widget _buildAvatar(ColorScheme colorScheme) {
    final String avatar = ImageUrlHelper.resolve(post.author.avatar ?? '');
    final bool hasAvatar = avatar.isNotEmpty;

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primary,
      backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
      child: hasAvatar
        ? null
        : Text(
            post.author.displayName.isNotEmpty ? post.author.displayName.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }

  Widget _buildMainImage(ColorScheme colorScheme) {
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
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
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

  Widget _buildOptionsMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20
      ),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Editar',
                style: TextStyle(
                  color: colorScheme.primary
                ),  
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: colorScheme.error
              ),
              SizedBox(width: 8),
              Text(
                'Eliminar',
                style: TextStyle(
                  color: colorScheme.error
                ),  
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
                    _buildAvatar(colorScheme),
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '· ${formatRelativeTime(post.createdAt)}',
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _authorTypeLabel,
                                style: TextStyle(fontSize: 12, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 6),
                              NewsTypeBadge(newsType: post.newsType),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (isOwn) _buildOptionsMenu(colorScheme),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onImageTap == null ? null : () => onImageTap!(0),
                child: _buildMainImage(colorScheme),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.content,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, height: 1.35),
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
                        Icon(Icons.mode_comment_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Text(
                          '${post.commentsCount}',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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