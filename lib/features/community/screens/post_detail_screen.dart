import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/community/community_routes.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/community/widgets/comment_field.dart';
import 'package:app_petfinder/features/community/widgets/comment_tile.dart';
import 'package:app_petfinder/features/community/widgets/post_card.dart';
import 'package:app_petfinder/models/community/community_author_model.dart';
import 'package:app_petfinder/models/community/community_comment_model.dart';
import 'package:app_petfinder/models/community/paginated.dart';
import 'package:app_petfinder/models/community/post_image_model.dart';
import 'package:app_petfinder/models/community/post_model.dart';
import 'package:app_petfinder/repository/community/community_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel? post;
  final CommunityAuthorModel? me;
  final CommunityRepository? repository;
  final ValueChanged<PostModel>? onPostChanged;

  const PostDetailScreen({
    super.key,
    this.post,
    this.me,
    this.repository,
    this.onPostChanged,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final CommunityRepository _communityRepository;
  final ScrollController _scrollController = ScrollController();

  PostModel? _post;
  final List<CommunityCommentModel> _comments = [];
  final Map<String, GlobalKey> _commentKeys = {};
  final Set<String> _expandedReplies = <String>{};
  CommunityCommentModel? _replyTo;
  CommunityAuthorModel? _me;

  bool _isLoadingPost = true;
  bool _isLoadingComments = true;
  bool _isLoadingMoreComments = false;
  bool _hasMoreComments = false;
  final int _limit = 20;
  int _commentsPage = 1;

  @override
  void initState() {
    super.initState();
    _communityRepository = widget.repository ?? CommunityRepository();
    _me = widget.me;
    _post = widget.post;
    _loadPost();
    if (_me == null) {
      _loadMeIfNeeded();
    }
    _loadComments(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMeIfNeeded() async {
    try {
      final response = await _communityRepository.getFormCatalog();
      if (!mounted) return;

      final data = response.data;
      if (data == null || data['me'] is! Map<String, dynamic>) return;

      setState(() {
        _me = CommunityAuthorModel.fromJson(data['me'] as Map<String, dynamic>);
      });
    } on ApiException {
    }
  }

  bool get _postIsOwn => _post?.isOwn(_me) ?? false;

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll * 0.8)) {
      if (!_isLoadingMoreComments && _hasMoreComments && !_isLoadingComments) {
        _loadComments();
      }
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadPost(),
      _loadComments(reset: true),
    ]);
  }

  Future<void> _loadPost() async {
    final postId = _post?.id;
    if (postId == null) {
      if (mounted) setState(() => _isLoadingPost = false);
      return;
    }

    try {
      final response = await _communityRepository.getPost(postId);
      if (!mounted) return;

      final data = response.data;
      if (data != null) {
        final loaded = PostModel.fromJson(data);

        setState(() {
          _post = loaded;
        });

        widget.onPostChanged?.call(loaded);
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      ApiErrorHandler.handle(context, e);
      if (e.code == 404) {
        context.pop();
        return;
      }
    } finally {
      if (mounted) setState(() => _isLoadingPost = false);
    }
  }

  Future<void> _loadComments({bool reset = false}) async {
    final postId = _post?.id;
    if (postId == null) return;

    if (reset) {
      setState(() {
        _isLoadingComments = true;
        _commentsPage = 1;
        _comments.clear();
      });
    } else {
      setState(() => _isLoadingMoreComments = true);
    }

    try {
      final response = await _communityRepository.getComments(postId, page: _commentsPage, limit: _limit);
      if (!mounted) return;

      final data = response.data;
      if (data == null) return;

      final paginated = Paginated<CommunityCommentModel>.fromJson(data, CommunityCommentModel.fromJson);

      setState(() {
        _comments.addAll(paginated.items);
        _hasMoreComments = paginated.hasMore;
        if (_hasMoreComments) _commentsPage++;
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
          _isLoadingMoreComments = false;
        });
      }
    }
  }

  Future<bool> _sendComment(String content) async {
    final postId = _post?.id;
    if (postId == null) return false;

    final replyTo = _replyTo;

    if (_me == null) {
      await _loadMeIfNeeded();
    }

    try {
      final response =
          await _communityRepository.createComment(postId, content, parentId: replyTo?.id);
      if (!mounted) return false;

      final data = response.data;

      if (data != null && data['id'] is String) {
        final newComment = CommunityCommentModel.fromJson(data);

        if (replyTo != null) {
          _expandRepliesFor(replyTo.id);
        }

        final updatedPost = replyTo == null
            ? _post?.copyWith(commentsCount: (_post?.commentsCount ?? 0) + 1)
            : null;

        setState(() {
          _comments.add(newComment);

          if (replyTo != null) {
            final index = _comments.indexWhere((c) => c.id == replyTo.id);
            if (index != -1) {
              _comments[index] =
                  _comments[index].copyWith(repliesCount: _comments[index].repliesCount + 1);
            }
          } else {
            _post = updatedPost;
          }

          _replyTo = null;
        });

        if (updatedPost != null) {
          widget.onPostChanged?.call(updatedPost);
        }

        FocusManager.instance.primaryFocus?.unfocus();
        _revealComment(newComment.id);
        return true;
      }

      final commentId = data?['comment_id'] as String?;
      final me = _me;

      if (commentId != null && me != null) {
        if (replyTo != null) {
          _expandRepliesFor(replyTo.id);
        }

        final updatedPost = replyTo == null
            ? _post?.copyWith(commentsCount: (_post?.commentsCount ?? 0) + 1)
            : null;

        setState(() {
          _comments.add(
            CommunityCommentModel(
              id: commentId,
              author: me,
              content: content,
              parentId: replyTo?.id,
              parent: replyTo == null
                  ? null
                  : CommentParentModel(
                      tutorId: replyTo.author.tutorId,
                      displayName: replyTo.author.displayName,
                    ),
              createdAt: DateTime.now(),
            ),
          );

          if (replyTo != null) {
            final index = _comments.indexWhere((c) => c.id == replyTo.id);
            if (index != -1) {
              _comments[index] =
                  _comments[index].copyWith(repliesCount: _comments[index].repliesCount + 1);
            }
          } else {
            _post = updatedPost;
          }

          _replyTo = null;
        });

        if (updatedPost != null) {
          widget.onPostChanged?.call(updatedPost);
        }

        FocusManager.instance.primaryFocus?.unfocus();
        _revealComment(commentId);
        return true;
      }

      if (mounted) {
        setState(() => _replyTo = null);
      }

      return false;
    } on ApiException catch (e) {
      if (!mounted) return false;
      ApiErrorHandler.handle(context, e);
      return false;
    }
  }

  void _revealComment(String commentId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = _commentKeys[commentId]?.currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.08,
      );
    });
  }

  void _startReply(CommunityCommentModel comment) {
    setState(() => _replyTo = comment);
  }

  void _cancelReply() {
    setState(() => _replyTo = null);
  }

  void _toggleReplies(String commentId) {
    setState(() {
      if (!_expandedReplies.add(commentId)) {
        _expandedReplies.remove(commentId);
      }
    });
  }

  void _expandRepliesFor(String commentId) {
    final chain = <String>{};
    String? current = commentId;

    while (current != null) {
      chain.add(current);
      final index = _comments.indexWhere((c) => c.id == current);
      current = index != -1 ? _comments[index].parentId : null;
    }

    _expandedReplies.addAll(chain);
  }

  Future<void> _editComment(CommunityCommentModel comment) async {
    final controller = TextEditingController(text: comment.content);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          minLines: 1,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Comentario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (saved != true) return;

    final newContent = controller.text.trim();
    if (newContent.isEmpty) return;

    try {
      final response = await _communityRepository.updateComment(comment.id, newContent);
      if (!mounted) return;

      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        setState(() {
          _comments[index] = comment.copyWith(content: newContent);
        });
      }

      ApiSuccessHandler.handle(context, title: 'Comentario actualizado', description: response.message);
    } on ApiException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    }
  }

  Future<void> _deleteComment(CommunityCommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que deseas eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _communityRepository.deleteComment(comment.id);
      if (!mounted) return;

      final removedIds = <String>{comment.id};
      final cursor = <String>[comment.id];

      while (cursor.isNotEmpty) {
        final children = _comments
            .where((c) => c.parentId != null && cursor.contains(c.parentId))
            .map((c) => c.id)
            .toList();

        removedIds.addAll(children);
        cursor
          ..clear()
          ..addAll(children);
      }

      final newCount = (_post?.commentsCount ?? 0) - removedIds.length;
      final updatedPost = _post?.copyWith(commentsCount: newCount < 0 ? 0 : newCount);

      setState(() {
        _comments.removeWhere((c) => removedIds.contains(c.id));
        _expandedReplies.removeAll(removedIds);

        if (updatedPost != null) {
          _post = updatedPost;
        }
      });

      if (updatedPost != null) {
        widget.onPostChanged?.call(updatedPost);
      }

      ApiSuccessHandler.handle(context, title: 'Comentario eliminado');
    } on ApiException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    }
  }

  Future<void> _editPost() async {
    final post = _post;
    if (post == null) return;

    final changed = await context.push<bool>(CommunityRoutes.postEdit, extra: post);
    if (changed == true && mounted) {
      _loadPost();
      _loadComments(reset: true);
    }
  }

  Future<void> _deletePost() async {
    final post = _post;
    if (post == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text('¿Seguro que deseas eliminar esta publicación? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _communityRepository.deletePost(post.id);
      if (!mounted) return;

      ApiSuccessHandler.handle(context, title: 'Publicación eliminada');
      context.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    }
  }

  void _openImageGallery(List<PostImageModel> images, int index) {
  context.push(
    CommunityRoutes.postImageViewer,
    extra: (images, index),
  );
}

  Future<({bool active, int count})> _handleReaction(bool activate) async {
    final postId = _post?.id;
    final currentPost = _post;
    if (postId == null || currentPost == null) {
      return (active: activate, count: currentPost?.reactionsCount ?? 0);
    }

    final response = activate
        ? await _communityRepository.toggleReaction(postId)
        : await _communityRepository.removeReaction(postId);

    final data = response.data ?? {};

    final result = (
      active: data['active'] as bool? ?? activate,
      count: data['reactions_count'] as int? ?? currentPost.reactionsCount,
    );

    if (mounted) {
      final updatedPost = currentPost.copyWith(
        reactedByMe: result.active,
        reactionsCount: result.count,
      );

      setState(() => _post = updatedPost);
      widget.onPostChanged?.call(updatedPost);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Publicación',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
          _buildCommentField(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final post = _post;
    if (post == null) {
      return _isLoadingPost
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : const Center(child: Text('La publicación no está disponible', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
        PostCard(
          post: post,
          isOwn: _postIsOwn,
          onTap: null,
          onImageTap: post.images.isNotEmpty
            ? (index) => _openImageGallery(post.images, index)
            : null,
          onEdit: _editPost,
          onDelete: _deletePost,
          onToggleReaction: _handleReaction,
        ),
        const SizedBox(height: 16),
        Text(
          'Comentarios',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 4),
        ..._buildCommentsSection(),
        const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildCommentsSection() {
    if (_isLoadingComments) {
      return const [
        Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(color: Colors.teal)),
        ),
      ];
    }

    if (_comments.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Aún no hay comentarios. ¡Sé el primero en comentar!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }

    return [
      ..._buildCommentsTree(),
      if (_isLoadingMoreComments)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator(color: Colors.teal)),
        ),
    ];
  }

  List<Widget> _buildCommentsTree() {
    final childrenByParent = <String?, List<CommunityCommentModel>>{};

    for (final comment in _comments) {
      childrenByParent.putIfAbsent(comment.parentId, () => []).add(comment);
    }

    final roots = childrenByParent[null] ?? const <CommunityCommentModel>[];

    return [
      for (final root in roots) _renderCommentNode(root, childrenByParent, 0),
    ];
  }

  Widget _renderCommentNode(
    CommunityCommentModel comment,
    Map<String?, List<CommunityCommentModel>> childrenByParent,
    int depth,
  ) {
    final canReply = depth < 2;
    final replies = childrenByParent[comment.id] ?? const <CommunityCommentModel>[];
    final isExpanded = _expandedReplies.contains(comment.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: _commentKeys.putIfAbsent(comment.id, GlobalKey.new),
          child: CommentTile(
            comment: comment,
            isOwn: comment.isOwn(_me),
            isRoot: depth == 0,
            canReply: canReply,
            onReply: canReply ? () => _startReply(comment) : null,
            onEdit: () => _editComment(comment),
            onDelete: () => _deleteComment(comment),
          ),
        ),
        if (replies.isNotEmpty && !isExpanded) _buildRepliesToggle(comment),
        if (replies.isNotEmpty && isExpanded) ...[
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.only(left: 20, top: 4, bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in replies)
                  _renderCommentNode(child, childrenByParent, depth + 1),
              ],
            ),
          ),
          _buildRepliesToggle(comment, expanded: true),
        ],
      ],
    );
  }

  Widget _buildRepliesToggle(CommunityCommentModel comment, {bool expanded = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: InkWell(
        onTap: () => _toggleReplies(comment.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded ? Icons.expand_less_rounded : Icons.chevron_right_rounded,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                expanded ? 'Ocultar respuestas' : 'Ver respuestas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: CommentField(
            onSend: _sendComment,
            replyToName: _replyTo?.author.displayName,
            onCancelReply: _replyTo != null ? _cancelReply : null,
          ),
        ),
      ),
    );
  }
}