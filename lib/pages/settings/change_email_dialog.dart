import 'package:flutter/material.dart';

class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({Key? key}) : super(key: key);

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  void _changeEmail() {
    if (_formKey.currentState!.validate()) {
      if (_newEmailController.text != _confirmEmailController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los correos no coinciden')),
        );
        return;
      }

      // Aquí implementarías la lógica para cambiar el email
      // Por ejemplo, llamar a tu API o servicio de autenticación

      Navigator.of(context).pop(true); // Retorna true si fue exitoso
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar correo electrónico'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentEmailController,
              decoration: const InputDecoration(
                labelText: 'Correo actual',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su correo actual';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newEmailController,
              decoration: const InputDecoration(
                labelText: 'Nuevo correo',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nuevo correo';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmEmailController,
              decoration: const InputDecoration(
                labelText: 'Confirmar nuevo correo',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme el nuevo correo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _changeEmail, child: const Text('Cambiar')),
      ],
    );
  }
}
