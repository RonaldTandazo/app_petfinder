enum UserRole { tutor, shelter }

class UserModel {
  final int id;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'shelter' ? UserRole.shelter : UserRole.tutor,
    );
  }
}