class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String username;
  final String? email;
  final String? name;
  final String? lastName;
  final String? role;

  User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.lastName,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'],
      name: json['name'],
      lastName: json['last_name'],
      role: json['role_name'],
    );
  }

  String get fullName {
    if (name != null && lastName != null) {
      return '$name $lastName';
    } else if (name != null) {
      return name!;
    } else {
      return username;
    }
  }
}