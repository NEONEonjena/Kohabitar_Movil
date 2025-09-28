import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Cambiar Contraseña', showBackButton: true),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Pantalla de cambio de contraseña'),
          ],
        ),
      ),
    );
  }
}
