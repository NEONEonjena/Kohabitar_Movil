import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../pages/providers/vehicle_provider.dart';
import './assign_vehicle_screen.dart';

class RegisteredVehiclesScreen extends StatefulWidget {
  const RegisteredVehiclesScreen({Key? key}) : super(key: key);

  @override
  State<RegisteredVehiclesScreen> createState() => _RegisteredVehiclesScreenState();
}

class _RegisteredVehiclesScreenState extends State<RegisteredVehiclesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }
  
  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Utilizamos el provider para cargar los vehículos
      await Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
    } catch (e) {
      // Cualquier error será gestionado por el provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar vehículos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VEHÍCULOS REGISTRADOS'),
        backgroundColor: const Color(0xFF05877C),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignVehicleScreen()),
          ).then((_) => _loadVehicles());
        },
        backgroundColor: const Color(0xFF05877C),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, child) {
                if (vehicleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (vehicleProvider.error != null) {
                  return _buildErrorView(message: vehicleProvider.error);
                } else if (vehicleProvider.vehicles.isEmpty) {
                  return _buildEmptyView();
                } else {
                  return _buildVehiclesList(vehicleProvider.vehicles);
                }
              },
            ),
    );
  }
  
  Widget _buildErrorView({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Error al cargar los vehículos',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF05877C),
            ),
            onPressed: _loadVehicles,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay vehículos registrados',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Registrar Vehículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF05877C),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssignVehicleScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildVehiclesList(List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Propiedad
                Text(
                  vehicle.propertyName ?? 'Propiedad no asignada',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 24),
                
                // Marca y Modelo
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.brandModel ?? '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Propietario
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.owner ?? 'Propietario no asignado',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Parqueadero asignado
                Row(
                  children: [
                    const Icon(Icons.local_parking, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.parkingSlot ?? 'Sin parqueadero asignado',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF05877C)),
                      onPressed: () {
                        // Navega a la pantalla de edición de vehículo
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(vehicle);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _showDeleteConfirmationDialog(Vehicle vehicle) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de que desea eliminar el vehículo ${vehicle.brandModel}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Usamos el provider para eliminar el vehículo
                final success = await Provider.of<VehicleProvider>(context, listen: false)
                  .deleteVehicle(vehicle.plate);
                
                if (!mounted) return;
                
                // Mostrar mensaje según resultado
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Vehículo eliminado con éxito' 
                      : 'Error al eliminar el vehículo'
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}