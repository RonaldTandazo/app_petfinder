import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/enums/adoption/view_mode.dart';
import 'package:app_petfinder/enums/skeleton/skeleton_view_mode.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/services/location_service.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';
import 'package:app_petfinder/features/adoption/widgets/adoption_search_bar.dart';
import 'package:app_petfinder/widgets/loaders/app_skeleton_loader.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_grid_view.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_view.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';
import 'package:app_petfinder/models/filters/pet_filter_model.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/filters/app_pet_filter_bottom_sheet.dart';

class AdoptionHomeScreen extends StatefulWidget {
  const AdoptionHomeScreen({super.key});

  @override
  State<AdoptionHomeScreen> createState() => _AdoptionHomeScreenState();
}

class _AdoptionHomeScreenState extends State<AdoptionHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _adoptionRepository = AdoptionRepository();
  final _catalogRepository = CatalogRepository();

  Timer? _debounceTimer;
  ViewMode _currentViewMode = ViewMode.grid;
  LatLng? _userLocation;

  PetFilterModel _activeFilters = PetFilterModel();
  Map<String, dynamic> _filtersData = {};
  int _requestId = 0;
  CancelToken? _cancelToken;

  final List<AdoptionPetListModel> _pets = [];
  
  bool _isLoadingPets = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

  SkeletonViewMode get _skeletonMode {
    switch (_currentViewMode) {
      case ViewMode.swipe:
        return SkeletonViewMode.swipe;
      case ViewMode.grid:
      return SkeletonViewMode.grid;
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadPetFilters();
    _loadAdoptionPets(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll * 0.8)) {
      if (!_isLoadingMore && _hasMore && !_isLoadingPets) {
        _loadAdoptionPets();
      }
    }
  }
  
  Future<void> _loadPetFilters() async {
    try {
      final response = await _catalogRepository.getPetCatalogs();
      if(!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null) {
          _filtersData = data;
        }
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    }
  }

  Future<void> _loadAdoptionPets({bool reset = false}) async {
    if (reset) {
      _cancelToken?.cancel('Nueva búsqueda iniciada');
      _cancelToken = CancelToken();

      setState(() {
        _isLoadingPets = true;
        _page = 1;
        _pets.clear();
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;

      setState(() => _isLoadingMore = true);
    }

    final currentRequestId = ++_requestId;

    final Map<String, dynamic> payload = {
      'page': _page,
      'limit': _limit,
      ..._activeFilters.toMap(),
    };

    try {
      final response = await _adoptionRepository.getAdoptionPets(payload, cancelToken: _cancelToken);
      
      if (currentRequestId != _requestId || !mounted) return;

      final data = response.data;

      if (data != null && data['pets'] is List) {
        final List newPetsJson = data['pets'];

        final newPets = newPetsJson
            .map((e) => AdoptionPetListModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _pets.addAll(newPets);
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
          _isLoadingPets = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _navigateToDetail(AdoptionPetListModel pet) {
    context.push(AdoptionRoutes.adoptionPet, extra: pet.id);
  }

  IconData _getToggleIcon() {
    switch (_currentViewMode) {
      case ViewMode.grid:
        return Icons.swipe_rounded;
      case ViewMode.swipe:
        return Icons.grid_view_rounded;
    }
  }

  void _toggleViewMode() {
    setState(() {
      _currentViewMode = _currentViewMode == ViewMode.grid ? ViewMode.swipe : ViewMode.grid;
    });
  }

  Future<void> _getUserLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() => _userLocation = location);
    }
  }

  String? _getDistanceForPet(AdoptionPetListModel pet) {
    if (_userLocation == null || pet.latitude == null || pet.longitude == null) {
      return null;
    }

    return LocationService.calculateFormattedDistance(
      userLocation: _userLocation!,
      targetLat: pet.latitude!,
      targetLng: pet.longitude!,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      if (_activeFilters.search != null) {
        setState(() {
          _activeFilters = _activeFilters.copyWith(search: () => null);
        });
        _loadAdoptionPets(reset: true);
      }
      return;
    }

    if (trimmedQuery.length < 3) {
      if (_activeFilters.search != null) {
        setState(() {
          _activeFilters = _activeFilters.copyWith(search: () => null);
        });
        _loadAdoptionPets(reset: true);
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (_activeFilters.search == trimmedQuery) return;

      setState(() {
        _activeFilters = _activeFilters.copyWith(search: () => trimmedQuery);
      });

      _loadAdoptionPets(reset: true);
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: AppPetFiltersBottomSheet(
            filtersData: _filtersData,
            currentFilters: _activeFilters,
            onApply: (newFilters) {
              setState(() => _activeFilters = newFilters);
              _loadAdoptionPets(reset: true);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          AdoptionSearchBar(
            onChanged: _onSearchChanged,
            onFilterTap: _openFilterBottomSheet,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoadingPets
                ? AppSkeletonLoader(mode: _skeletonMode)
                : RefreshIndicator(
                    color: Colors.teal,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await _loadAdoptionPets(reset: true);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentViewMode == ViewMode.grid
                        ? PetGridView(
                            controller: _scrollController,
                            pets: _pets,
                            isLoadingMore: _isLoadingMore,
                            getDistance: _getDistanceForPet,
                            onTap: _navigateToDetail,
                            emptyStateWidget: const AppEmptyState(
                              icon: Icons.pets,
                              description: 'No hay mascotas en adopción'
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: PetSwipeView(
                                    pets: _pets,
                                    getDistance: _getDistanceForPet,
                                    onTap: _navigateToDetail,
                                    onDismissed: (index) {
                                      setState(() => _pets.removeAt(index));

                                      if (_pets.length <= 3 && _hasMore && !_isLoadingMore) {
                                        _loadAdoptionPets();
                                      }
                                    },
                                    emptyStateWidget: const AppEmptyState(
                                      icon: Icons.pets,
                                      description: 'No hay mascotas en adopción',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Ubicación actual',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
          ),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.teal),
              SizedBox(width: 4),
              Text(
                'Guayaquil, Ecuador',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_getToggleIcon(), color: Colors.teal),
          tooltip: 'Cambiar Vista',
          onPressed: _toggleViewMode,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}