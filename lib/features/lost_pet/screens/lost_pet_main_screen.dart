
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/core/services/location_service.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/repository/lost_pet/lost_pet_repository.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_list_model.dart';
import 'package:app_petfinder/features/adoption/widgets/species_selector_chips.dart';
import 'package:app_petfinder/features/lost_pet/widgets/lost_pet_card.dart';
import 'package:app_petfinder/widgets/loaders/app_skeleton_loader.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';

class LostPetHomeScreen extends StatefulWidget {
  const LostPetHomeScreen({super.key});

  @override
  State<LostPetHomeScreen> createState() => _LostPetHomeScreenState();
}

class _LostPetHomeScreenState extends State<LostPetHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _lostPetRepository = LostPetRepository();

  String _selectedCategory = 'Todos';
  final List<LostPetListModel> _lostPets = [];
  
  LatLng? _userLocation;
  bool _isLoadingLostPets = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

 final List<String> _categories = ['Todos', 'Perros', 'Gatos', 'Otros'];

  List<LostPetListModel> get _filteredLostPets {
    if (_selectedCategory == 'Todos') return _lostPets;
    return _lostPets.where((p) => p.species == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadLostPets(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll * 0.8)) {
      if (!_isLoadingMore && _hasMore && !_isLoadingLostPets) {
        _loadLostPets();
      }
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
      setState(() {
        _isLoadingLostPets = true;
        _page = 1;
        _lostPets.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final Map<String, dynamic> payload = {
      'page': _page,
      'limit': _limit
    };

    try {
      final response = await _lostPetRepository.getLostPets(payload);
      if (!mounted) return;

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
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mascotas Perdidas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.teal),
            onPressed: () {
              // TODO: Abrir filtros avanzados de radio/distancia
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btn_report_lost_pet',
        onPressed: () {
          context.push(LostPetRoutes.publish);
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'Reportar Mascota',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          CategorySelectorChips(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),

          Expanded(
            child:  _isLoadingLostPets
              ? AppSkeletonLoader(mode: SkeletonViewMode.list) 
              : RefreshIndicator(
                  color: Colors.teal,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await _loadLostPets(reset: true);
                  },
                  child: _filteredLostPets.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          AppEmptyState(
                            icon: Icons.pets,
                            description: 'No hay reportes de mascotas perdidas',
                          ),
                        ],
                      )
                    : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredLostPets.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredLostPets.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.teal),
                            ),
                          );
                        }

                        final lostPet = _filteredLostPets[index];
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