import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/enums/skeleton/skeleton_view_mode.dart';
import 'package:app_petfinder/core/services/location_service.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/repository/lost_pet/lost_pet_repository.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_list_model.dart';
import 'package:app_petfinder/features/lost_pet/widgets/lost_pet_card.dart';
import 'package:app_petfinder/widgets/loaders/app_skeleton_loader.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:app_petfinder/features/adoption/widgets/adoption_search_bar.dart';
import 'package:app_petfinder/models/filters/pet_filter_model.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/filters/app_pet_filter_bottom_sheet.dart';

class LostPetHomeScreen extends StatefulWidget {
  const LostPetHomeScreen({super.key});

  @override
  State<LostPetHomeScreen> createState() => _LostPetHomeScreenState();
}

class _LostPetHomeScreenState extends State<LostPetHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final LostPetRepository _lostPetRepository = LostPetRepository();
  final CatalogRepository _catalogRepository = CatalogRepository();

  Timer? _debounceTimer;
  LatLng? _userLocation;

  PetFilterModel _activeFilters = PetFilterModel();
  Map<String, dynamic> _filtersData = {};
  int _requestId = 0;
  CancelToken? _cancelToken;

  final List<LostPetListModel> _lostPets = [];
  
  bool _isLoadingLostPets = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadPetFilters();
    _loadLostPets(reset: true);
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

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final threshold = position.maxScrollExtent * 0.8;

    if (position.pixels >= threshold && !_isLoadingMore && _hasMore && !_isLoadingLostPets) {
      _loadLostPets();
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

  Future<void> _getUserLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() => _userLocation = location);
    }
  }

  String? _getDistanceForPet(LostPetListModel pet) {
    if (_userLocation == null || pet.latitude == null || pet.longitude == null) {
      return null;
    }

    return LocationService.calculateFormattedDistance(
      userLocation: _userLocation!,
      targetLat: pet.latitude!,
      targetLng: pet.longitude!,
    );
  }

  Future<void> _loadLostPets({bool reset = false}) async {
    if (reset) {
      _cancelToken?.cancel('Nueva búsqueda iniciada');
      _cancelToken = CancelToken();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      setState(() {
        _isLoadingLostPets = true;
        _isLoadingMore = false;
        _page = 1;
        _hasMore = false;
        _lostPets.clear();
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
      final response = await _lostPetRepository.getLostPets(payload, cancelToken: _cancelToken);
      if (currentRequestId != _requestId || !mounted) return;

      final data = response.data;

      if (data != null && data['lost_pets'] is List) {
        final List newLostPetsJson = data['lost_pets'];

        final newLostPets = newLostPetsJson
            .map((e) => LostPetListModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _lostPets.addAll(newLostPets);
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
          _isLoadingLostPets = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _navigateToDetail(LostPetListModel lostPet) {
    context.push(LostPetRoutes.lostPetDetail, extra: lostPet.id);
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
        _loadLostPets(reset: true);
      }
      return;
    }

    if (trimmedQuery.length < 3) {
      if (_activeFilters.search != null) {
        setState(() {
          _activeFilters = _activeFilters.copyWith(search: () => null);
        });
        _loadLostPets(reset: true);
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (_activeFilters.search == trimmedQuery) return;

      setState(() {
        _activeFilters = _activeFilters.copyWith(search: () => trimmedQuery);
      });

      _loadLostPets(reset: true);
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
            showHealthConditions: false,
            onApply: (newFilters) {
              setState(() => _activeFilters = newFilters);
              _loadLostPets(reset: true);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mascotas Perdidas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isSmallPhone ? 18 : 20,
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final double buttonHeight = isSmallPhone
            ? 34.0
            : isTablet
                ? 64.0
                : 40.0;

          final double iconSize = isSmallPhone
            ? 20.0
            : isTablet
                ? 28.0
                : 24.0;

          final double fontSize = isSmallPhone
            ? 11.0
            : isTablet
                ? 16.0
                : 13.0;

          final double horizontalPadding = 7;

          return SizedBox(
            height: buttonHeight,
            child: FloatingActionButton.extended(
              heroTag: 'btn_report_lost_pet',
              onPressed: () {
                context.push(LostPetRoutes.publish);
              },
              backgroundColor: Colors.redAccent,
              elevation: 4,
              icon: Icon(
                Icons.add_location_alt_rounded,
                color: Colors.white,
                size: iconSize,
              ),
              label: Text(
                'Reportar Mascota',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              extendedPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          AdoptionSearchBar(
            onChanged: _onSearchChanged,
            onFilterTap: _openFilterBottomSheet,
          ),
          const SizedBox(height: 12),
          Expanded(
            child:  _isLoadingLostPets
              ? AppSkeletonLoader(mode: SkeletonViewMode.list) 
              : RefreshIndicator(
                  color: Colors.teal,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await _loadLostPets(reset: true);
                  },
                  child: _lostPets.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          AppEmptyState(
                            icon: Icons.search_off,
                            description: 'No hay reportes de mascotas perdidas',
                          ),
                        ],
                      )
                    : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _lostPets.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _lostPets.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.teal),
                            ),
                          );
                        }

                        final lostPet = _lostPets[index];
                        final distance = _getDistanceForPet(lostPet);
                        
                        return LostPetCard(
                          lostPet: lostPet,
                          distance: distance,
                          onTap: _navigateToDetail,
                        );
                      },
                    ),
                ),
          ),
        ],
      ),
    );
  }
}