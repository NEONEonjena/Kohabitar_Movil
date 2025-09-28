import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/appbar.dart';
import '../../widgets/navigation_drawer.dart';
import '../user/user.dart';
import '../auth/login.dart';
import '../providers/auth_provider.dart';
import '../settings/settings_page.dart' as settings;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
  }

  void _onDrawerItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _logout() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    _pages = [
      HomeContent(username: auth.username ?? 'Invitado'),
      UserScreen(username: auth.username ?? '', password: auth.password ?? ''),
      const settings.SettingsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: _getTitle(),
        showBackButton: false,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(
        username: auth.username ?? 'Invitado',
        currentIndex: _currentIndex,
        onItemSelected: _onDrawerItemSelected,
        onLogout: _logout,
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
        return 'Perfil De Usuario';
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
            'Bienvenido, $username!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Column(
              children: [
                Icon(Icons.home, size: 50, color: Colors.purple),
                SizedBox(height: 20),
                Text(
                  'Esta es la pantalla de inicio. Aquí puedes ver un resumen de tu actividad reciente y acceder a las diferentes secciones de la aplicación.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
