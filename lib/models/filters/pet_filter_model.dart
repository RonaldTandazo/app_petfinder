class PetFilterModel {
  final String? search;
  final List<int> speciesIds;
  final List<int> genderIds;
  final List<int> sizeIds;
  final List<int> healthConditionIds;

  PetFilterModel({
    this.search,
    this.speciesIds = const [],
    this.genderIds = const [],
    this.sizeIds = const [],
    this.healthConditionIds = const [],
  });

  bool get isEmpty => (search == null || search!.isEmpty) && speciesIds.isEmpty && genderIds.isEmpty && sizeIds.isEmpty && healthConditionIds.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (speciesIds.isNotEmpty) 'species': speciesIds,
      if (genderIds.isNotEmpty) 'genders': genderIds,
      if (sizeIds.isNotEmpty) 'sizes': sizeIds,
      if (healthConditionIds.isNotEmpty) 'health_conditions': healthConditionIds,
    };
  }

  PetFilterModel copyWith({
    String? Function()? search,
    List<int>? speciesIds,
    List<int>? genderIds,
    List<int>? sizeIds,
    List<int>? healthConditionIds,
  }) {
    return PetFilterModel(
      search: search != null ? search() : this.search,
      speciesIds: speciesIds ?? this.speciesIds,
      genderIds: genderIds ?? this.genderIds,
      sizeIds: sizeIds ?? this.sizeIds,
      healthConditionIds: healthConditionIds ?? this.healthConditionIds,
    );
  }
}