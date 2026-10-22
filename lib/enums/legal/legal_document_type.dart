enum LegalDocumentType {
  terms,
  privacy,
  unknown;

  static LegalDocumentType fromString(String? tag) {
    switch (tag) {
      case 'TERMS':
        return LegalDocumentType.terms;
      case 'PRIVACY':
        return LegalDocumentType.privacy;
      default:
        return LegalDocumentType.unknown;
    }
  }

  String toTag() {
    switch (this) {
      case LegalDocumentType.terms:
        return 'TERMS';
      case LegalDocumentType.privacy:
        return 'PRIVACY';
      default:
        return 'UNKNOWN';
    }
  }
}