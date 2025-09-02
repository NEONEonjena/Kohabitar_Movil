import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'widgets/screens/users_screen.dart';
import 'widgets/screens/properties_screen.dart';
import 'widgets/screens/parkingZone_screen.dart';
import 'widgets/screens/visitors_screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

// -------------------- PANTALLA DE LOGIN --------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/logo1.png', height: 100),
              const SizedBox(height: 10),
              const Text('KOHABITAR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Ingresar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                  );
                },
                child: const Text('¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- PANTALLA RESET PASSWORD --------------------
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/logo1.png', height: 100),
              const SizedBox(height: 10),
              const Text('KOHABITAR',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 40),
              _buildInput('Usuario'),
              const SizedBox(height: 20),
              _buildInput('Correo Electrónico'),
              const SizedBox(height: 20),
              _buildInput('Nueva Contraseña', obscure: true),
              const SizedBox(height: 20),
              _buildInput('Confirmar Contraseña', obscure: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Guardar Cambios',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('← Volver al inicio de sesión',
                    style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
      ),
    );
  }
}

// -------------------- DASHBOARD CON MENÚ --------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _currentScreen = const DashboardContent();

  void _navigateTo(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.pop(context); // Cierra el drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KOHABITAR', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      drawer: AppDrawer(onNavigate: _navigateTo),
      body: _currentScreen,
    );
  }
}

// El contenido original del dashboard
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildPieChartCard(),
          const SizedBox(height: 16),
          _buildBarChartCard(),
          const SizedBox(height: 16),
          _buildActivitiesCard(),
        ],
      ),
    );
  }


  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('15', 'Visitantes de Hoy', Icons.person),
        _buildStatCard('15', 'Usuarios Inactivos', Icons.person_off),
        _buildStatCard('75%', 'Propiedades Ocupadas', Icons.home),
        _buildStatCard('120', 'Usuarios Activos', Icons.group),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.teal),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Ocupación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: Colors.teal, value: 65, title: '65%'),
                    PieChartSectionData(color: Colors.grey.shade300, value: 35, title: ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Usuarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.teal)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.teal)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6, color: Colors.teal)]),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Actividades Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Carlos actualizó su perfil'),
            Text('• Maria deshabilitó su cuenta'),
            Text('• Se registró una nueva propiedad en la torre 103'),
          ],
        ),
      ),
    );
  }
}

// -------------------- MENÚ HAMBURGUESA --------------------
typedef DrawerNavigate = void Function(Widget screen);

class AppDrawer extends StatelessWidget {
  final DrawerNavigate? onNavigate;
  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.teal,
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              "MENU",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(context, Icons.dashboard, "Dashboard", () {
                  if (onNavigate != null) onNavigate!(const DashboardContent());
                }),
                _buildDrawerItem(context, Icons.person, "Usuarios", () {
                  if (onNavigate != null) onNavigate!(UsersScreen());
                }),
                _buildDrawerItem(context, Icons.home, "Propiedades", () {
                  if (onNavigate != null) onNavigate!(PropertiesScreen());
                }),
                _buildDrawerItem(context, Icons.local_parking, "Parqueaderos", () {
                  if (onNavigate != null) onNavigate!(ParkingZoneScreen());
                }),
                _buildDrawerItem(context, Icons.badge, "Visitantes", () {
                  if (onNavigate != null) onNavigate!(VisitorsScreens());
                }),
                _buildDrawerItem(context, Icons.meeting_room, "Zonas Comunes", () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(context, Icons.payment, "Pagos", () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(context, Icons.bar_chart, "Reportes", () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(context, Icons.notifications, "Notificaciones", () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(context, Icons.inventory, "Paquetes", () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(context, Icons.support, "PQRs", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/img/user.png'), // Foto del usuario
            ),
            title: const Text("Luisa Pereira"),
            subtitle: const Text("luisa.pereira@gmail.com"),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: onTap,
    );
  }
}
