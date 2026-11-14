import 'package:app_petfinder/core/helpers/image_url_helper.dart';
import 'package:app_petfinder/core/helpers/relative_time_helper.dart';
import 'package:app_petfinder/models/community/community_comment_model.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  final CommunityCommentModel comment;
  final bool isOwn;
  final bool isRoot;
  final bool canReply;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    this.isOwn = false,
    this.isRoot = true,
    this.canReply = true,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  Widget _buildAvatar(ColorScheme colorScheme) {
    final String avatar = ImageUrlHelper.resolve(comment.author.avatar ?? '');
    final bool hasAvatar = avatar.isNotEmpty;

    return CircleAvatar(
      radius: isRoot ? 18 : 13,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
      child: hasAvatar
        ? null
        : Text(
            comment.author.displayName.isNotEmpty
                ? comment.author.displayName.substring(0, 1).toUpperCase()
                : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: isRoot ? 15 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }

  Widget _buildShelterBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Refugio',
        style: TextStyle(
          fontSize: 9,
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNameRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Flexible(
          child: Text(
            comment.author.displayName,
            style: TextStyle(
              fontSize: isRoot ? 14 : 12.5,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (comment.author.isShelter) ...[
          const SizedBox(width: 6),
          _buildShelterBadge(colorScheme),
        ],
        const Spacer(),
        Text(
          formatRelativeTime(comment.createdAt),
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant
          ),
        ),
      ],
    );
  }

  Widget _buildReplyTag(ColorScheme colorScheme) {
    final parentName = comment.parentName ?? '';
    if (parentName.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.subdirectory_arrow_right_rounded,
          size: 14,
          color: colorScheme.primary
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            'respondió a @$parentName',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: onReply,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.reply_rounded,
              size: 14,
              color: colorScheme.primary
            ),
            const SizedBox(width: 4),
            Text(
              'Responder',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Row(
      children: [
        if (comment.repliesCount > 0) ...[
          Text(
            '· ${comment.repliesCount} ${comment.repliesCount == 1 ? 'respuesta' : 'respuestas'}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (canReply && onReply != null) _buildReplyButton(colorScheme),
      ],
    );
  }

  Widget _buildRootContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameRow(colorScheme),
        const SizedBox(height: 6),
        Text(
          comment.content,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            height: 1.35
          ),
        ),
        const SizedBox(height: 4),
        _buildFooter(colorScheme),
      ],
    );
  }

  Widget _buildReplyContent(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameRow(colorScheme),
          const SizedBox(height: 2),
          _buildReplyTag(colorScheme),
          const SizedBox(height: 5),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
              height: 1.35
            ),
          ),
          const SizedBox(height: 3),
          _buildFooter(colorScheme),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(colorScheme),
          const SizedBox(width: 10),
          Expanded(
            child: isRoot ? _buildRootContent(colorScheme) : _buildReplyContent(colorScheme),
          ),
          if (isOwn)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20
              ),
              padding: EdgeInsets.zero,
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
                        color: colorScheme.primary
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
            ),
        ],
      ),
    );
  }
}