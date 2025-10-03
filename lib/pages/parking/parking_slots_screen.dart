import 'package:flutter/material.dart';
import '../../models/parking_slot.dart';
import '../../services/parking_service.dart';

class ParkingSlotsScreen extends StatefulWidget {
  const ParkingSlotsScreen({Key? key}) : super(key: key);

  @override
  State<ParkingSlotsScreen> createState() => _ParkingSlotsScreenState();
}

class _ParkingSlotsScreenState extends State<ParkingSlotsScreen> {
  final ParkingService _parkingService = ParkingService();
  late Future<List<ParkingSlot>> _slotsFuture;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Estado del filtro aplicado
  String _filterValue = 'all';

  @override
  void initState() {
    super.initState();
    _loadParkingSlots();
  }
  
  Future<void> _loadParkingSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      _slotsFuture = _parkingService.getAllParkingSlots();
      await _slotsFuture;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los parqueaderos: $e';
      });
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
        title: const Text('PARQUEADEROS ASIGNADOS'),
        backgroundColor: const Color(0xFF05877C),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParkingSlots,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Opciones de filtrado
          _buildFilterSection(),
          
          // Lista de parqueaderos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : FutureBuilder<List<ParkingSlot>>(
                        future: _slotsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return _buildErrorView(message: snapshot.error.toString());
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyView();
                          } else {
                            final filteredSlots = _filterSlots(snapshot.data!);
                            return _buildParkingSlotsList(filteredSlots);
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  // Filtra los parqueaderos según su estado
  List<ParkingSlot> _filterSlots(List<ParkingSlot> slots) {
    switch (_filterValue) {
      case 'available':
        return slots.where((slot) => !slot.isReserved).toList();
      case 'occupied':
        return slots.where((slot) => slot.isReserved).toList();
      default:
        return slots;
    }
  }
  
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Filtrar por: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          
          // Filtro de todos
          _buildFilterChip(
            label: 'Todos',
            value: 'all',
            icon: Icons.list,
          ),
          const SizedBox(width: 8),
          
          // Filtro de disponibles
          _buildFilterChip(
            label: 'Disponibles',
            value: 'available',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 8),
          
          // Filtro de ocupados
          _buildFilterChip(
            label: 'Ocupados',
            value: 'occupied',
            icon: Icons.car_rental,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _filterValue == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF05877C),
      checkmarkColor: Colors.white,
      onSelected: (bool selected) {
        setState(() {
          _filterValue = value;
        });
      },
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
            message ?? _errorMessage ?? 'Error al cargar los parqueaderos',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF05877C),
            ),
            onPressed: _loadParkingSlots,
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
            Icons.local_parking,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _filterValue == 'all'
                ? 'No hay parqueaderos asignados'
                : _filterValue == 'available'
                    ? 'No hay parqueaderos disponibles'
                    : 'No hay parqueaderos ocupados',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParkingSlotsList(List<ParkingSlot> slots) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
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
                Row(
                  children: [
                    // Código del parqueadero
                    Text(
                      'Parqueadero ${slot.code}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    
                    // Indicador de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: slot.isReserved 
                          ? Colors.red.withOpacity(0.2) 
                          : const Color(0xFF05877C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            slot.isReserved 
                              ? Icons.cancel_outlined
                              : Icons.check_circle_outline,
                            size: 16,
                            color: slot.isReserved 
                              ? Colors.red 
                              : const Color(0xFF05877C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            slot.isReserved ? 'Ocupado' : 'Disponible',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: slot.isReserved 
                                ? Colors.red
                                : const Color(0xFF05877C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 24),
                
                // Información de la propiedad
                if (slot.propertyName != null)
                  _buildInfoRow(
                    icon: Icons.home,
                    label: 'Propiedad',
                    value: slot.propertyName!,
                  ),
                  
                // Información de la zona
                if (slot.zoneType != null)
                  _buildInfoRow(
                    icon: Icons.grid_view,
                    label: 'Zona',
                    value: slot.zoneType!,
                  ),
                
                // Información de tarifa
                if (slot.tariffAmount != null && slot.timeUnit != null)
                  _buildInfoRow(
                    icon: Icons.attach_money,
                    label: 'Tarifa',
                    value: '\$${slot.tariffAmount} por ${_getTimeUnitText(slot.timeUnit!)}',
                  ),
                
                // Botones de acción
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón de editar
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF05877C),
                      ),
                    ),
                    
                    // Botón de liberar (si está ocupado)
                    if (slot.isReserved)
                      TextButton.icon(
                        onPressed: () => _showReleaseDialog(slot),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Liberar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                      
                    // Botón de asignar (si está disponible)
                    if (!slot.isReserved)
                      TextButton.icon(
                        onPressed: () => _showAssignDialog(slot),
                        icon: const Icon(Icons.directions_car, size: 18),
                        label: const Text('Asignar'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF05877C),
                        ),
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
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTimeUnitText(String timeUnit) {
    switch (timeUnit.toLowerCase()) {
      case 'day':
        return 'día';
      case 'week':
        return 'semana';
      case 'month':
        return 'mes';
      case 'year':
        return 'año';
      default:
        return timeUnit;
    }
  }
  
  Future<void> _showReleaseDialog(ParkingSlot slot) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Liberar parqueadero'),
          content: Text('¿Está seguro de que desea liberar el parqueadero ${slot.code}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _releaseSlot(slot);
              },
              child: const Text('Liberar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showAssignDialog(ParkingSlot slot) async {
    final vehicles = ['PA-152', 'ABC123', 'XYZ789'];
    String? selectedVehicle;
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Asignar vehículo a ${slot.code}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Seleccione un vehículo:'),
                  const SizedBox(height: 16),
                  ...vehicles.map((plate) => RadioListTile<String>(
                    title: Text(plate),
                    value: plate,
                    groupValue: selectedVehicle,
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value;
                      });
                    },
                  )),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: selectedVehicle == null ? null : () async {
                Navigator.of(context).pop();
                await _assignVehicleToSlot(slot, selectedVehicle!);
              },
              child: const Text('Asignar'),
              style: TextButton.styleFrom(
                foregroundColor: selectedVehicle == null 
                  ? Colors.grey 
                  : const Color(0xFF05877C),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _releaseSlot(ParkingSlot slot) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _parkingService.releaseVehicleFromSlot(slot.code);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parqueadero liberado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadParkingSlots();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al liberar el parqueadero: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _assignVehicleToSlot(ParkingSlot slot, String vehiclePlate) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _parkingService.assignVehicleToSlot(slot.code, vehiclePlate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehículo asignado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadParkingSlots();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al asignar el vehículo: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}