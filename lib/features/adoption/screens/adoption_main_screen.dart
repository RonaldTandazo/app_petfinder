import 'package:app_petfinder/core/router/pet/pet_routes.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/widgets/state/app_empty_state.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/features/adoption/widgets/adoption_search_bar.dart';
import 'package:app_petfinder/widgets/loaders/app_skeleton_loader.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_grid_view.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_view.dart';
import 'package:app_petfinder/features/adoption/widgets/species_selector_chips.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';
import 'package:go_router/go_router.dart';

enum ViewMode { grid, swipe }

class AdoptionHomeScreen extends StatefulWidget {
  const AdoptionHomeScreen({super.key});

  @override
  State<AdoptionHomeScreen> createState() => _AdoptionHomeScreenState();
}

class _AdoptionHomeScreenState extends State<AdoptionHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _adoptionRepository = AdoptionRepository();

  ViewMode _currentViewMode = ViewMode.grid;
  String _selectedCategory = 'Todos';
  
  final List<AdoptionPetModel> _pets = [];
  
  bool _isLoadingPets = true;
  bool _isLoadingMore = true;
  bool _hasMore = false;
  final int _limit = 20;
  int _page = 1;

  final List<String> _categories = ['Todos', 'Perros', 'Gatos', 'Otros'];

  List<AdoptionPetModel> get _filteredPets {
    if (_selectedCategory == 'Todos') return _pets;
    return _pets.where((p) => p.species == _selectedCategory).toList();
  }

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
    _loadAdoptionPets(reset: true);
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
      if (!_isLoadingMore && _hasMore && !_isLoadingPets) {
        _loadAdoptionPets();
      }
    }
  }

  Future<void> _loadAdoptionPets({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingPets = true;
        _page = 1;
        _pets.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final Map<String, dynamic> payload = {
      'page': _page,
      'limit': _limit
    };

    try {
      final response = await _adoptionRepository.getAdoptionPets(payload);
      if (!mounted) return;

      final data = response.data;

      if (data != null && data['pets'] is List) {
        final List newPetsJson = data['pets'];

        final newPets = newPetsJson
            .map((e) => AdoptionPetModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _pets.addAll(newPets);
          _hasMore = data['hasMore'] ?? false;
          if (_hasMore) _page++;
        });
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _navigateToDetail(AdoptionPetModel pet) {
    context.push(PetRoutes.petDetail, extra: pet);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          AdoptionSearchBar(
            onChanged: (value) {
              // TODO: Implementar búsqueda local o por API
            },
          ),
          CategorySelectorChips(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoadingPets
                ? AppSkeletonLoader(mode: _skeletonMode)
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentViewMode == ViewMode.grid
                      ? PetGridView(
                          pets: _filteredPets,
                          onTap: _navigateToDetail,
                          emptyStateWidget: const AppEmptyState(description: 'No hay mascotas en adopción'),
                        )
                      : _currentViewMode == ViewMode.swipe
                        ? PetSwipeView(
                            pets: _filteredPets,
                            onTap: _navigateToDetail,
                            onDismissed: (index) {
                              setState(() => _pets.removeAt(index));

                              if (_pets.length <= 3 && _hasMore && !_isLoadingMore) {
                                _loadAdoptionPets();
                              }
                            },
                            emptyStateWidget: const AppEmptyState(description: 'No hay mascotas en adopción'),
                          )
                        : PetGridView( // Nota: Reemplazar por PetListView cuando esté construido
                            pets: _filteredPets,
                            onTap: _navigateToDetail,
                            emptyStateWidget: const AppEmptyState(description: 'No hay mascotas en adopción'),
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