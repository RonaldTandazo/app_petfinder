import 'package:app_petfinder/models/catalog/country_summary_model.dart';
import 'package:app_petfinder/models/catalog/gender_summary_model.dart';

sealed class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.email,
    this.country,
    this.tutorId,
    this.createdAt = '',
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('first_names')) {
      return UserProfileModel.fromJson(json);
    }
    return ShelterProfileModel.fromJson(json);
  }

  final int id;
  final String email;
  final CountrySummaryModel? country;
  final int? tutorId;
  final String createdAt;
}

class UserProfileModel extends AccountProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.country,
    super.tutorId,
    super.createdAt,
    this.firstNames = '',
    this.lastNames = '',
    this.fullName = '',
    this.telephone = '',
    this.city = '',
    this.address = '',
    this.avatar = '',
    this.gender,
  });

  final String firstNames;
  final String lastNames;
  final String fullName;
  final String telephone;
  final String city;
  final String address;
  final String avatar;
  final GenderSummaryModel? gender;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      country: json['country'] == null
          ? null
          : CountrySummaryModel.fromJson(json['country'] as Map<String, dynamic>),
      tutorId: json['tutor_id'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      firstNames: json['first_names'] as String? ?? '',
      lastNames: json['last_names'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      gender: json['gender'] == null
          ? null
          : GenderSummaryModel.fromJson(json['gender'] as Map<String, dynamic>),
    );
  }
}

class ShelterProfileModel extends AccountProfile {
  const ShelterProfileModel({
    required super.id,
    required super.email,
    super.country,
    super.tutorId,
    super.createdAt,
    this.name = '',
    this.businessName = '',
    this.taxIdentification = '',
    this.telephone = '',
    this.physicalAddress = '',
    this.city = '',
    this.latitude,
    this.longitude,
    this.webPage = '',
    this.businessHours = '',
    this.logo = '',
    this.verified = false,
  });

  final String name;
  final String businessName;
  final String taxIdentification;
  final String telephone;
  final String physicalAddress;
  final String city;
  final String? latitude;
  final String? longitude;
  final String webPage;
  final String businessHours;
  final String logo;
  final bool verified;

  factory ShelterProfileModel.fromJson(Map<String, dynamic> json) {
    return ShelterProfileModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      country: json['country'] == null
          ? null
          : CountrySummaryModel.fromJson(json['country'] as Map<String, dynamic>),
      tutorId: json['tutor_id'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      name: json['name'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      taxIdentification: json['tax_identification'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      physicalAddress: json['physical_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      webPage: json['web_page'] as String? ?? '',
      businessHours: json['business_hours'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
    );
  }
}