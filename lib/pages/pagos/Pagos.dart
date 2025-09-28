import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagos UI',
      theme: ThemeData(
        primaryColor: const Color(0xFF26A69A),
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PagosScreen(),
        '/administracion': (context) => const AdministracionScreen(),
      },
    );
  }
}

class PagosScreen extends StatelessWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            _buildChartCard(
              context: context,
              title: 'SANCIONES',
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF4DB6AC),
                  value: 80,
                  title: '80%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF00796B),
                  value: 20,
                  title: '20%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              legend: const [
                LegendItem(color: Color(0xFF4DB6AC), text: 'Sanciones Totales'),
                LegendItem(color: Color(0xFF00796B), text: 'Sanciones Pagadas'),
              ],
            ),
            const SizedBox(height: 24),
            _buildChartCard(
              context: context,
              title: 'ADMINISTRACIÓN',
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF4DB6AC),
                  value: 57.1,
                  title: '57.1%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF00796B),
                  value: 42.9,
                  title: '42.9%',
                  radius: 70,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              legend: const [
                LegendItem(color: Color(0xFF4DB6AC), text: 'Faltantes'),
                LegendItem(color: Color(0xFF00796B), text: 'Pagados'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildChartCard({
  required BuildContext context,
  required String title,
  required List<PieChartSectionData> sections,
  required List<LegendItem> legend,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00695C),
          ),
        ),
        const SizedBox(height: 20), // 👈 separa título y gráfica
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(children: legend),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/administracion');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            elevation: 5,
          ),
          child: const Text('Ver Detalle'),
        ),
      ],
    ),
  );
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class AdministracionScreen extends StatelessWidget {
  const AdministracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administración"),
        backgroundColor: const Color(0xFF26A69A),
      ),
      body: const Center(
        child: Text(
          "Aquí se mostrará el detalle de administración",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
