import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../widgets/navigation_drawer.dart';
import '../user/user.dart';
import '../auth/login.dart';
import '../settings/settings_page.dart';
import '../zonas_comunes/zonas_comunes_page.dart';
import '../notificaciones/notificaciones_page.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const HomeScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(username: widget.username), // 0 Usuarios
      UserScreen(
          username: widget.username,
          password: widget.password), // 1 Propiedades
      const SettingsPage(), // 2 Parqueaderos
      Container(child: Center(child: Text('Visitantes'))), // 3 Visitantes
      ZonasComunesPage(), // 4 Zonas Comunes
      Container(child: Center(child: Text('Pagos'))), // 5 Pagos
      Container(child: Center(child: Text('Reportes'))), // 6 Reportes
      NotificacionesPage(), // 7 Notificaciones
      Container(child: Center(child: Text('Paquetes'))), // 8 Paquetes
      Container(child: Center(child: Text('PQRs'))), // 9 PQRs
    ];
  }

  void _onDrawerItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: _getTitle(),
        showBackButton: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value =
                  Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      drawer: CustomDrawer(
        username: widget.username,
        onItemSelected: _onDrawerItemSelected,
        onLogout: _logout,
        currentIndex: _currentIndex,
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Perfil';
      case 2:
        return 'Configuración';
      default:
        return 'Mi App';
    }
  }
}

class HomeContent extends StatelessWidget {
  final String username;

  const HomeContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, $username!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.home, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text('Esta es la pantalla principal de la aplicación'),
                  SizedBox(height: 10),
                  Text(
                    'Usa el menú lateral o la barra de navegación inferior para explorar las diferentes secciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildFeatureCard(Icons.person, 'Perfil', Colors.blue),
              _buildFeatureCard(Icons.settings, 'Configuración', Colors.green),
              _buildFeatureCard(
                  Icons.notifications, 'Notificaciones', Colors.orange),
              _buildFeatureCard(Icons.help, 'Ayuda', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
