import 'dart:async';

import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/community/community_routes.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/features/community/widgets/feed_skeleton.dart';
import 'package:app_petfinder/features/community/widgets/post_card.dart';
import 'package:app_petfinder/features/community/widgets/reaction_button.dart';
import 'package:app_petfinder/models/community/community_author_model.dart';
import 'package:app_petfinder/models/community/paginated.dart';
import 'package:app_petfinder/models/community/post_model.dart';
import 'package:app_petfinder/repository/community/community_repository.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _communityRepository = CommunityRepository();
  final ScrollController _scrollController = ScrollController();

  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _hasSearchText = false;

  final List<PostModel> _posts = [];
  CommunityAuthorModel? _me;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadFormCatalog();
    _loadPosts(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();

    setState(() {
      _hasSearchText = value.isNotEmpty;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || query == _query) return;
      _query = query;
      _loadPosts(reset: true);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _hasSearchText = false;
      _query = '';
    });

    _loadPosts(reset: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll * 0.8)) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadPosts();
      }
    }
  }

  Future<void> _loadFormCatalog() async {
    try {
      final response = await _communityRepository.getFormCatalog();
      if (!mounted) return;

      final data = response.data;
      if (data == null || data['me'] is! Map<String, dynamic>) return;

      setState(() {
        _me = CommunityAuthorModel.fromJson(data['me'] as Map<String, dynamic>);
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    }
  }

  Future<void> _loadPosts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _page = 1;
        _posts.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await _communityRepository.getPosts(page: _page, limit: _limit, q: _query);
      if (!mounted) return;

      final data = response.data;
      if (data == null) return;

      final paginated = Paginated<PostModel>.fromJson(data, PostModel.fromJson);

      setState(() {
        _posts.addAll(paginated.items);
        _hasMore = paginated.hasMore;
        if (_hasMore) _page++;
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() => _loadPosts(reset: true);

  Future<ReactionResult> _handleReaction(String postId, bool activate) async {
    final response = activate
        ? await _communityRepository.toggleReaction(postId)
        : await _communityRepository.removeReaction(postId);

    final data = response.data ?? {};

    return (
      active: data['active'] as bool? ?? activate,
      count: data['reactions_count'] as int? ?? 0,
    );
  }

  void _applyReactionResult(PostModel post, ReactionResult result) {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    setState(() {
      _posts[index] = post.copyWith(
        reactedByMe: result.active,
        reactionsCount: result.count,
      );
    });
  }

  Future<void> _navigateToDetail(PostModel post) async {
    final deleted = await context.push<bool>(
      CommunityRoutes.postDetail,
      extra: (post, _me, _applyPostUpdate),
    );
    if (deleted == true && mounted) {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        setState(() => _posts.removeAt(index));
      }
    }
  }

  void _applyPostUpdate(PostModel updated) {
    final index = _posts.indexWhere((p) => p.id == updated.id);
    if (index == -1 || !mounted) return;

    setState(() => _posts[index] = updated);
  }

  Future<void> _navigateToCreate() async {
    final changed = await context.push<bool>(CommunityRoutes.postCreate);
    if (changed == true && mounted) {
      _loadPosts(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPublish = _me?.isShelter ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Comunidad',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (canPublish)
            IconButton(
              icon: const Icon(Icons.post_add_rounded, color: Colors.teal),
              tooltip: 'Crear publicación',
              onPressed: _navigateToCreate,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildFeedContent()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Busca por título, contenido o autor...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.teal),
            suffixIcon: _hasSearchText
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_isLoading) {
      return const FeedSkeleton();
    }

    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            AppEmptyState(
              icon: _query.isEmpty ? Icons.forum_outlined : Icons.search_off_rounded,
              title: _query.isEmpty ? 'Sin publicaciones todavía' : 'Sin resultados',
              description: _query.isEmpty
                  ? 'Aún no hay publicaciones en la comunidad. ¡Vuelve pronto!'
                  : 'No encontramos publicaciones para "$_query". Prueba con otras palabras.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: Colors.teal)),
            );
          }

          final post = _posts[index];

          return PostCard(
            post: post,
            onTap: () => _navigateToDetail(post),
            onToggleReaction: (activate) => _handleReaction(post.id, activate),
            onReactionResult: (result) => _applyReactionResult(post, result),
          );
        },
      ),
    );
  }
}