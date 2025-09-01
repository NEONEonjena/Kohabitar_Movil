import 'package:flutter/material.dart';
import '/models/user.dart';
import '/widgets/base_screen.dart';
import '/widgets/items/user_item.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<User> users = [
    User(
      name: "Juan Pérez",
      role: "Administrador",
      status: "Activo",
      avatar: "assets/images/user1.jpg",
    ),
    User(
      name: "Andrés Parra",
      role: "Administrador",
      status: "Inactivo",
      avatar: "assets/images/user2.jpg",
    ),
    User(
      name: "María Suárez",
      role: "Propietario",
      status: "Activo",
      avatar: "assets/images/user3.jpg",
    ),
    User(
      name: "Ramón Pérez",
      role: "Residente",
      status: "Activo",
      avatar: "assets/images/user4.jpg",
    ),
    User(
      name: "Carlos Ruíz",
      role: "Vigilante",
      status: "Activo",
      avatar: "assets/images/user5.jpg",
    ),
    User(
      name: "María Rodríguez",
      role: "Propietario",
      status: "Activo",
      avatar: "assets/images/user6.jpg",
    ),
    User(
      name: "José Díaz",
      role: "Administrador",
      status: "Inactivo",
      avatar: "assets/images/user7.jpg",
    ),
    User(
      name: "Luisa Pereira",
      role: "Administrador",
      status: "Activo",
      avatar: "assets/images/user8.jpg",
    ),
    User(
      name: "Juan Pérez",
      role: "Administrador",
      status: "Activo",
      avatar: "assets/images/user9.jpg",
    ),
  ];

  void _onMenuPressed() {
    // Implementar lógica del menú
    print("Menú presionado en Usuarios");
  }

  void _onNotificationPressed() {
    // Implementar lógica de notificaciones
    print("Notificaciones presionadas en Usuarios");
  }

  void _onUserMorePressed(User user) {
    // Implementar acciones específicas para cada usuario
    print("Más opciones para: ${user.name}");
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'USUARIOS',
      onMenuPressed: _onMenuPressed,
      onNotificationPressed: _onNotificationPressed,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserItem(
            user: user,
            onMorePressed: () => _onUserMorePressed(user),
          );
        },
      ),
    );
  }
}
