import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../widgets/appbar.dart';
import '../home/home.dart';
import '../user/form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _registeredUsername;
  String? _registeredPassword;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _registeredUsername ?? '';
    _passwordController.text = _registeredPassword ?? '';
  }

  void _navigateToRegistration() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserFormScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _registeredUsername = result['username'];
        _registeredPassword = result['password'];
        _usernameController.text = _registeredUsername ?? '';
        _passwordController.text = _registeredPassword ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso.')),
      );
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Guardamos la sesión en el provider
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.login(username, password);

        print('Login successful, navigating to home...'); // Debug

        // Redirigimos al Home usando pushAndRemoveUntil para limpiar el stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } catch (e) {
        print('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error durante el login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img/logos/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (email)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su usuario';
                  }
                  const emailPattern =
                      r'^[^@]+@[^@]+\.[^@]+$'; // Simple email validation
                  if (!RegExp(emailPattern).hasMatch(value)) {
                    return 'Por favor ingrese un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }

                  const passwordPattern =
                      r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Za-z0-9]).{8,16}$';
                  if (!RegExp(passwordPattern).hasMatch(value)) {
                    return 'La contraseña debe tener entre 8 y 16 caracteres, '
                        'al menos un dígito, una minúscula, una mayúscula y un carácter especial';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: _navigateToRegistration,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
