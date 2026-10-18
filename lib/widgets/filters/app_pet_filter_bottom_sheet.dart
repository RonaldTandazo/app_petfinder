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
  State<AppPetFiltersBottomSheet> createState() =>
      _AppPetFiltersBottomSheetState();
}

class _AppPetFiltersBottomSheetState
    extends State<AppPetFiltersBottomSheet> {
  late List<int> _selectedSpecies;
  late List<int> _selectedGenders;
  late List<int> _selectedSizes;
  late List<int> _selectedHealthConditions;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = List<int>.from(widget.currentFilters.speciesIds);
    _selectedGenders = List<int>.from(widget.currentFilters.genderIds);
    _selectedSizes = List<int>.from(widget.currentFilters.sizeIds);
    _selectedHealthConditions =
        List<int>.from(widget.currentFilters.healthConditionIds);
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
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;
    final bool isShortScreen = screenSize.height < 650;

    final double horizontalPadding = isSmallPhone
        ? 12
        : isMobile
            ? 16
            : 24;

    final double verticalPadding = isSmallPhone ? 10 : 16;
    final double titleFontSize = isSmallPhone ? 18 : 20;
    final double sectionFontSize = isSmallPhone ? 14 : 15;
    final double chipSpacing = isSmallPhone ? 5 : 8;

    final speciesList = widget.filtersData['species'] as List? ?? [];
    final gendersList = widget.filtersData['genders'] as List? ?? [];
    final sizesList = widget.filtersData['sizes'] as List? ?? [];
    final healthList = widget.filtersData['health_conditions'] as List? ?? [];

    return SafeArea(
      top: false,
      child: Container(
        height: screenSize.height * (isShortScreen ? 0.92 : 0.80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          isSmallPhone ? 8 : 12,
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(
                  bottom: isSmallPhone ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 4 : 8,
                    ),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _clearAll,
                  child: Text(
                    'Limpiar todo',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: isSmallPhone ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  if (widget.showSpecies)
                    _buildFilterSection(
                      'Especie',
                      speciesList,
                      _selectedSpecies,
                      sectionFontSize,
                      chipSpacing,
                      isSmallPhone,
                    ),

                  if (widget.showGenders)
                    _buildFilterSection(
                      'Género',
                      gendersList,
                      _selectedGenders,
                      sectionFontSize,
                      chipSpacing,
                      isSmallPhone,
                    ),

                  if (widget.showSizes)
                    _buildFilterSection(
                      'Tamaño',
                      sizesList,
                      _selectedSizes,
                      sectionFontSize,
                      chipSpacing,
                      isSmallPhone,
                    ),

                  if (widget.showHealthConditions)
                    _buildFilterSection(
                      'Condición de salud',
                      healthList,
                      _selectedHealthConditions,
                      sectionFontSize,
                      chipSpacing,
                      isSmallPhone,
                    ),
                ],
              ),
            ),

            SizedBox(height: isSmallPhone ? 8 : 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallPhone ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final appliedFilters = PetFilterModel(
                    speciesIds: widget.showSpecies
                        ? List<int>.from(_selectedSpecies)
                        : [],
                    genderIds: widget.showGenders
                        ? List<int>.from(_selectedGenders)
                        : [],
                    sizeIds: widget.showSizes
                        ? List<int>.from(_selectedSizes)
                        : [],
                    healthConditionIds: widget.showHealthConditions
                        ? List<int>.from(_selectedHealthConditions)
                        : [],
                  );

                  widget.onApply(appliedFilters);
                  Navigator.pop(context);
                },
                child: Text(
                  'Aplicar filtros',
                  style: TextStyle(
                    fontSize: isSmallPhone ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List items,
    List<int> selectedList,
    double titleFontSize,
    double chipSpacing,
    bool isSmallPhone,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isSmallPhone ? 6 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmallPhone ? 6 : 8),
          Wrap(
            spacing: chipSpacing,
            runSpacing: isSmallPhone ? 2 : 4,
            children: items.map<Widget>((item) {
              final int id = item['id'] as int;
              final String name = item['name'] as String;
              final bool isSelected = selectedList.contains(id);

              return FilterChip(
                label: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: isSmallPhone
                    ? const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      )
                    : VisualDensity.standard,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 2 : 4,
                ),
                selected: isSelected,
                selectedColor: Colors.teal.shade100,
                checkmarkColor: Colors.teal.shade900,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.teal.shade900
                      : Colors.black87,
                  fontSize: isSmallPhone ? 12 : 14,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.teal
                        : Colors.transparent,
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