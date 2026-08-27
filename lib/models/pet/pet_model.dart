class PetModel {
  final int id;
  final String name;
  final String speciesTag;
  final String species;
  final String? race;
  final String? color;
  final String bornDate;
  final int animalGenderTag;
  final String animalGender;
  final int sizeTag;
  final String size;
  final String? description;
  final int petStatusTag;
  final int petStatus;
  final String age;

  PetModel({
    required this.id,
    required this.name,
    required this.speciesTag,
    required this.species,
    this.race,
    this.color,
    required this.bornDate,
    required this.animalGenderTag,
    required this.animalGender,
    required this.sizeTag,
    required this.size,
    this.description,
    required this.petStatusTag,
    required this.petStatus,
    required this.age,
  });
}