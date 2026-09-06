class PetFilterModel {
  final List<int> speciesIds;
  final List<int> genderIds;
  final List<int> sizeIds;
  final List<int> healthConditionIds;

  PetFilterModel({
    this.speciesIds = const [],
    this.genderIds = const [],
    this.sizeIds = const [],
    this.healthConditionIds = const [],
  });

  bool get isEmpty =>
      speciesIds.isEmpty &&
      genderIds.isEmpty &&
      sizeIds.isEmpty &&
      healthConditionIds.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      if (speciesIds.isNotEmpty) 'species': speciesIds,
      if (genderIds.isNotEmpty) 'genders': genderIds,
      if (sizeIds.isNotEmpty) 'sizes': sizeIds,
      if (healthConditionIds.isNotEmpty) 'health_conditions': healthConditionIds,
    };
  }

  PetFilterModel copyWith({
    List<int>? speciesIds,
    List<int>? genderIds,
    List<int>? sizeIds,
    List<int>? healthConditionIds,
  }) {
    return PetFilterModel(
      speciesIds: speciesIds ?? this.speciesIds,
      genderIds: genderIds ?? this.genderIds,
      sizeIds: sizeIds ?? this.sizeIds,
      healthConditionIds: healthConditionIds ?? this.healthConditionIds,
    );
  }
}