class UserModel {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}
