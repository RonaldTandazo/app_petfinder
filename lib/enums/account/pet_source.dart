enum PetSource { 
  adoption,
  lost,
  unknown;

  static PetSource fromString(String? type) {
    switch (type) {
      case 'adoption':
        return PetSource.adoption;
      case 'lost_pet':
        return PetSource.lost;
      default:
        return PetSource.unknown;
    }
  }
}