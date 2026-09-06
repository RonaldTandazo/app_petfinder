import 'package:flutter/material.dart';
import 'package:app_petfinder/models/filters/pet_filter_model.dart';

class AppPetFiltersBottomSheet extends StatefulWidget {
  final Map<String, dynamic> filtersData;
  final PetFilterModel currentFilters;
  final ValueChanged<PetFilterModel> onApply;

  final bool showSpecies;
  final bool showGenders;
  final bool showSizes;
  final bool showHealthConditions;

  const AppPetFiltersBottomSheet({
    super.key,
    required this.filtersData,
    required this.currentFilters,
    required this.onApply,
    this.showSpecies = true,
    this.showGenders = true,
    this.showSizes = true,
    this.showHealthConditions = true,
  });

  @override
  State<AppPetFiltersBottomSheet> createState() => _AppPetFiltersBottomSheetState();
}

class _AppPetFiltersBottomSheetState extends State<AppPetFiltersBottomSheet> {
  late List<int> _selectedSpecies;
  late List<int> _selectedGenders;
  late List<int> _selectedSizes;
  late List<int> _selectedHealthConditions;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = List.from(widget.currentFilters.speciesIds);
    _selectedGenders = List.from(widget.currentFilters.genderIds);
    _selectedSizes = List.from(widget.currentFilters.sizeIds);
    _selectedHealthConditions = List.from(widget.currentFilters.healthConditionIds);
  }

  void _toggleSelection(List<int> list, int id) {
    setState(() {
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedSpecies.clear();
      _selectedGenders.clear();
      _selectedSizes.clear();
      _selectedHealthConditions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final speciesList = widget.filtersData['species'] as List? ?? [];
    final gendersList = widget.filtersData['genders'] as List? ?? [];
    final sizesList = widget.filtersData['sizes'] as List? ?? [];
    final healthList = widget.filtersData['health_conditions'] as List? ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearAll,
                child: const Text('Limpiar todo', style: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
          const Divider(),

          // Secciones de Filtros según props
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                if (widget.showSpecies)
                  _buildFilterSection('Especie', speciesList, _selectedSpecies),

                if (widget.showGenders)
                  _buildFilterSection('Género', gendersList, _selectedGenders),

                if (widget.showSizes)
                  _buildFilterSection('Tamaño', sizesList, _selectedSizes),

                if (widget.showHealthConditions)
                  _buildFilterSection('Condición de Salud', healthList, _selectedHealthConditions),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Botón de Aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final appliedFilters = PetFilterModel(
                  speciesIds: widget.showSpecies ? _selectedSpecies : [],
                  genderIds: widget.showGenders ? _selectedGenders : [],
                  sizeIds: widget.showSizes ? _selectedSizes : [],
                  healthConditionIds: widget.showHealthConditions ? _selectedHealthConditions : [],
                );
                widget.onApply(appliedFilters);
                Navigator.pop(context);
              },
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List items, List<int> selectedList) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map((item) {
              final id = item['id'] as int;
              final name = item['name'] as String;
              final isSelected = selectedList.contains(id);

              return FilterChip(
                label: Text(name),
                selected: isSelected,
                selectedColor: Colors.teal.shade100,
                checkmarkColor: Colors.teal.shade900,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.teal.shade900 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.teal : Colors.transparent,
                  ),
                ),
                onSelected: (_) => _toggleSelection(selectedList, id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}