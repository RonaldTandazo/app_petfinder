import 'package:flutter/material.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/widgets/app_snackbar.dart';
import 'package:app_petfinder/features/adoption/widgets/adoption_search_bar.dart';
import 'package:app_petfinder/features/adoption/widgets/adoption_skeleton_loader.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_grid_view.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_view.dart';
import 'package:app_petfinder/features/adoption/widgets/species_selector_chips.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';

enum ViewMode { grid, swipe }

class AdoptionHomeScreen extends StatefulWidget {
  const AdoptionHomeScreen({super.key});

  @override
  State<AdoptionHomeScreen> createState() => _AdoptionHomeScreenState();
}

class _AdoptionHomeScreenState extends State<AdoptionHomeScreen> {
  final _adoptionRepository = AdoptionRepository();

  ViewMode _currentViewMode = ViewMode.grid;
  String _selectedCategory = 'Todos';
  List<AdoptionPetModel> _pets = [];
  bool _isLoadingPets = true;

  final List<String> _categories = ['Todos', 'Perros', 'Gatos', 'Otros'];

  List<AdoptionPetModel> get _filteredPets {
    if (_selectedCategory == 'Todos') return _pets;
    return _pets.where((p) => p.species == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAdoptionPets();
  }

  Future<void> _loadAdoptionPets() async {
    try {
      final response = await _adoptionRepository.getAdoptionPets();
      if (!mounted) return;

      final data = response.data;
      setState(() {
        if (data != null && data['pets'] is List) {
          _pets = (data['pets'] as List)
              .map((e) => AdoptionPetModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      String errorDetail = e.message;

      if (e.error is Map<String, dynamic>) {
        final validationErrors = e.error as Map<String, dynamic>;
        final firstKey = validationErrors.keys.first;
        errorDetail = validationErrors[firstKey][0];
      }

      AppSnackBar.show(
        context,
        title: errorDetail,
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingPets = false);
      }
    }
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
                ? AdoptionSkeletonLoader(isGrid: _currentViewMode == ViewMode.grid)
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentViewMode == ViewMode.grid
                        ? PetGridView(
                            pets: _filteredPets,
                            emptyStateWidget: _buildEmptyState(),
                          )
                        : PetSwipeView(
                            pets: _filteredPets,
                            onDismissed: (index) {
                              setState(() => _pets.removeAt(index));
                            },
                            emptyStateWidget: _buildEmptyState(),
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
          icon: Icon(
            _currentViewMode == ViewMode.grid ? Icons.style_rounded : Icons.grid_view_rounded,
            color: Colors.teal,
          ),
          tooltip: 'Cambiar Vista',
          onPressed: () {
            setState(() {
              _currentViewMode = _currentViewMode == ViewMode.grid
                  ? ViewMode.swipe
                  : ViewMode.grid;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No hay mascotas disponibles en esta categoría.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}