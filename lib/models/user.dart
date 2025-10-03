/**
 * Modelo de Usuario
 * 
 * Esta clase representa un usuario en la aplicación.
 * Contiene sus datos básicos y métodos para convertir entre objeto y JSON.
 */

class User {
  // Datos principales del usuario
  final int id;
  final String username;
  final String? email;
  final String? name;
  final String? lastName;
  final String? role;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Constructor
  User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.lastName,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Nombre completo del usuario (combina nombre y apellido)
  String get fullName {
    if (name != null && lastName != null) {
      return '$name $lastName';
    } else if (name != null) {
      return name!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username; // Si no hay nombre ni apellido, usa el username
    }
  }

  // Crea un usuario a partir de un mapa JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'],
      name: json['name'],
      lastName: json['last_name'],
      role: json['role_name'],
      status: json['status_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // Convierte el usuario a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email': email,
      'name': name,
      'last_name': lastName,
      'role_name': role,
      'status_name': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Usuario: $username (ID: $id), Email: $email, Nombre: $fullName, Rol: $role, Estado: $status';
  }
}