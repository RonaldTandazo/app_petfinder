import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/core/services/location_service.dart';
import 'package:app_petfinder/features/follow/widgets/follow_summary_card.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/models/account/metric_model.dart';
import 'package:app_petfinder/models/follow/follow_pet_list_model.dart';
import 'package:app_petfinder/repository/follow/follow_repository.dart';
import 'package:app_petfinder/styles/app_form_styles.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/enums/account/pet_source.dart';
import 'package:app_petfinder/features/follow/widgets/follow_pet_card.dart';
import 'package:app_petfinder/features/follow/widgets/follow_pets_skeleton.dart';

class FollowPetsScreen extends StatefulWidget {
  const FollowPetsScreen({super.key});

  @override
  State<FollowPetsScreen> createState() => _FollowPetsScreenState();
}

class _FollowPetsScreenState extends State<FollowPetsScreen> {
  final FollowRepository _followRepository = FollowRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'ALL';
  LatLng? _userLocation;

  final List<MetricModel> _counters = [];
  final List<FollowPetListModel> _follows = [];
  
  bool _isLoadingIndex = true;
  bool _isLoadingFollows = true;
  bool _isLoadingMore = false;

  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

  int _requestId = 0;
  CancelToken? _cancelToken;

  List<FollowPetListModel> get _filteredFollows {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _follows;

    return _follows.where((pet) {
      return pet.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _getUserLocation();
    _loadInit();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInit() {
    _loadIndex(reset: true);
    _loadFollows(reset: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isLoadingFollows || _isLoadingMore || !_hasMore) return;

    final position = _scrollController.position;

    if (position.maxScrollExtent <= 0) {
      _loadFollows();
      return;
    }

    final threshold = position.maxScrollExtent * 0.8;

    if (position.pixels >= threshold) {
      _loadFollows();
    }
  }

  Future<void> _getUserLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() => _userLocation = location);
    }
  }

  String? _getDistanceForPet(FollowPetListModel pet) {
    if (_userLocation == null || pet.latitude == null || pet.longitude == null) {
      return null;
    }

    return LocationService.calculateFormattedDistance(
      userLocation: _userLocation!,
      targetLat: pet.latitude!,
      targetLng: pet.longitude!,
    );
  }

  Future<void> _loadIndex({bool reset = false}) async {
    if (reset) {
      _cancelToken?.cancel('Nueva búsqueda iniciada');
      _cancelToken = CancelToken();

      setState(() {
        _isLoadingIndex = true;
        _counters.clear();
      });
    }

    try {
      final response = await _followRepository.petPetFollowindex();
      if (!mounted) return;

      final data = response.data;

      if(data != null){
        if (data['counters'] is List) {
          final List counterJson = data['counters'];
          final newCounters = counterJson
              .map((e) => MetricModel.fromJson(e as Map<String, dynamic>))
              .toList();

          setState(() => _counters.addAll(newCounters));
        }
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoadingIndex = false);
    }
  }

  Future<void> _loadFollows({bool reset = false}) async {
    if (reset) {
      _cancelToken?.cancel('Nueva búsqueda iniciada');
      _cancelToken = CancelToken();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      setState(() {
        _isLoadingFollows = true;
        _isLoadingMore = false;
        _page = 1;
        _hasMore = false;
        _follows.clear();
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;

      setState(() => _isLoadingMore = true);
    }

    final currentRequestId = ++_requestId;

    final Map<String, dynamic> payload = {
      'page': _page,
      'limit': _limit,
      'category': _selectedFilter.toLowerCase(),
    };

    try {
      final response = await _followRepository.getPetFollows(payload, cancelToken: _cancelToken);
      if (currentRequestId != _requestId || !mounted) return;

      final data = response.data;

      if (data != null && data['follows'] is List) {
        final newFollows = (data['follows'] as List)
            .map(
              (e) => FollowPetListModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();

        setState(() {
          _follows.addAll(newFollows);
          _hasMore = data['hasMore'] ?? false;
          if (_hasMore) _page++;
        });
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;

      if (currentRequestId != _requestId || !mounted) return;

      ApiErrorHandler.handle(
        context, 
        ApiException(message: 'Error de red inesperado', code: 500),
      );
    } on ApiException catch (e) {
      if (currentRequestId != _requestId) return;

      ApiErrorHandler.handle(context, e);
    } finally {
      if (currentRequestId == _requestId && mounted) {
        setState(() {
          _isLoadingFollows = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
    });

    _loadFollows(reset: true);
  }

  void _handleTap(int id, PetSource source) {
    switch (source) {
      case PetSource.adoption:
        context.push(AdoptionRoutes.adoptionPet, extra: id);
        break;

      case PetSource.lost:
        context.push(LostPetRoutes.lostPet, extra: id);
        break;

      case PetSource.unknown:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          final double horizontalPadding = width < 360
              ? 12.0
              : width < 600
                  ? 16.0
                  : width < 900
                      ? 24.0
                      : 32.0;

          final double maxContentWidth = width >= 1200
              ? 1120.0
              : double.infinity;

          final int crossAxisCount = width < 600
            ? 2
            : width < 900
                ? 3
                : 4;

          final double spacing = width < 600 ? 10 : 16;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  _searchController.clear();
                  _loadInit();
                },
                color: colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _isLoadingIndex
                            ? FollowSummarySkeleton(width: width)
                            : _buildSummary(colorScheme, width),

                          const SizedBox(height: 22),

                          _isLoadingFollows && _follows.isEmpty
                              ? const FollowSearchSkeleton()
                              : TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  textInputAction: TextInputAction.search,
                                  decoration: AppFormStyles.inputDecoration(
                                    context,
                                    'Busca por nombre...',
                                    Icons.search,
                                  ),
                                ),

                          const SizedBox(height: 22),
                        ]),
                      ),
                    ),

                    if (_isLoadingFollows && _follows.isEmpty)
                      FollowCardsSkeleton(
                        width: width,
                        crossAxisCount: crossAxisCount,
                        spacing: spacing,
                        horizontalPadding: horizontalPadding,
                      )
                    else if (_filteredFollows.isEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300,
                          child: AppEmptyState(
                            icon: Icons.pets,
                            title: _searchController.text.trim().isNotEmpty
                                ? 'No encontramos coincidencias'
                                : 'No encontramos favoritos',
                            description: _searchController.text.trim().isNotEmpty
                                ? 'Prueba con otro nombre'
                                : 'Prueba con otra categoría o vuelve a intentarlo',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pet = _filteredFollows[index];

                              return FollowPetCard(
                                name: pet.name,
                                imageUrl: pet.picture,
                                distance: _getDistanceForPet(pet),
                                onTap: () => _handleTap(pet.petId, pet.type),
                              );
                            },
                            childCount: _filteredFollows.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: 0.85,
                          ),
                        ),
                      ),

                    if (_isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(
    ColorScheme colorScheme,
    double availableWidth,
  ) {
    final bool isSmallPhone = availableWidth < 360;
    final bool isMobile = availableWidth < 600;

    final double spacing = isSmallPhone ? 8 : 10;

    final int columns = isSmallPhone ? 2 : 3;

    final double itemWidth = isSmallPhone
        ? (availableWidth - spacing) / columns
        : (availableWidth - spacing * 2) / columns;

    final List<Widget> cards = _counters.map((c) {
      final IconData icon = c.tag == 'ALL' ? Icons.favorite_rounded : c.tag == 'ADOPTION' ? Icons.home_rounded : Icons.search_off_outlined;

      return FollowSummaryCard(
        title: c.label,
        count: c.count,
        icon: icon,
        color: colorScheme.primary,
        selected: _selectedFilter == c.tag,
        onTap: () => _onFilterChanged(c.tag),
      );
    }).toList();

    if (isSmallPhone) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: cards.map((card) {
          return SizedBox(
            width: itemWidth,
            child: card,
          );
        }).toList(),
      );
    }

    if (isMobile) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}