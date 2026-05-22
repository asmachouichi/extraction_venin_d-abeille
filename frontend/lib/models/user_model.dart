class UserModel {
  final int? id;
  final String username;
  final String email;
  final String role;
  final String? token;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "user",
      token: json["token"],
    );
  }
} 