import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/parking_slot.dart';
import '../providers/parking_slot_provider.dart';

class ParkingSlotListScreen extends StatefulWidget {
  final int? parkingZoneId;
  
  const ParkingSlotListScreen({super.key, this.parkingZoneId});

  @override
  _ParkingSlotListScreenState createState() => _ParkingSlotListScreenState();
}

class _ParkingSlotListScreenState extends State<ParkingSlotListScreen> {
  String _currentFilter = 'all'; // 'all', 'available', 'reserved'
  late TextEditingController _searchController;
  List<ParkingSlot> _filteredSlots = [];
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSlots);
    
    // Cargamos los datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterSlots);
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadInitialData() async {
    final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
    
    try {
      if (widget.parkingZoneId != null) {
        // Si se proporcionó un ID de zona, cargamos los slots de esa zona
        print('Cargando espacios para la zona ${widget.parkingZoneId}');
        await provider.loadSlotsByZone(widget.parkingZoneId!);
      } else {
        // De lo contrario, cargamos todos los slots
        print('Cargando todos los espacios de parqueo');
        await provider.loadAllSlots();
      }
      // Aplicamos el filtro después de cargar los datos
      _applyFilter();
      
      // Debug: mostrar cuántos slots se cargaron
      print('Slots cargados: ${provider.allSlots.length}');
      if (widget.parkingZoneId != null) {
        print('Slots de zona cargados: ${provider.currentZoneSlots.length}');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }
  
  void _filterSlots() {
    _applyFilter();
  }
  
  void _applyFilter() {
    final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
    final searchText = _searchController.text.toLowerCase();
    
    List<ParkingSlot> baseList;
    
    // Seleccionamos la lista base según el filtro
    switch (_currentFilter) {
      case 'available':
        if (widget.parkingZoneId != null) {
          baseList = provider.currentZoneSlots.where((slot) => !slot.isReserved).toList();
        } else {
          baseList = provider.availableSlots;
        }
        break;
      case 'reserved':
        if (widget.parkingZoneId != null) {
          baseList = provider.currentZoneSlots.where((slot) => slot.isReserved).toList();
        } else {
          baseList = provider.reservedSlots;
        }
        break;
      case 'all':
      default:
        baseList = widget.parkingZoneId != null ? provider.currentZoneSlots : provider.allSlots;
    }
    
    // Aplicamos el filtro de búsqueda
    if (searchText.isEmpty) {
      setState(() {
        _filteredSlots = baseList;
      });
    } else {
      setState(() {
        _filteredSlots = baseList.where((slot) {
          return slot.code.toLowerCase().contains(searchText) ||
                 (slot.propertyName?.toLowerCase().contains(searchText) ?? false) ||
                 (slot.statusName?.toLowerCase().contains(searchText) ?? false);
        }).toList();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parkingZoneId != null 
          ? 'Espacios de la Zona' 
          : 'Espacios de Parqueo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<ParkingSlotProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (_filteredSlots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay espacios de parqueo disponibles',
                          textAlign: TextAlign.center,
                        ),
                        if (widget.parkingZoneId != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir Espacio'),
                            onPressed: () => _showAddSlotDialog(context),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                
                return _buildParkingSlotsGrid();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.parkingZoneId != null
          ? FloatingActionButton(
              onPressed: () => _showAddSlotDialog(context),
              tooltip: 'Añadir Espacio',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar espacio de parqueo',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterChip('Todos', 'all'),
              _buildFilterChip('Disponibles', 'available'),
              _buildFilterChip('Reservados', 'reserved'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String filter) {
    return FilterChip(
      label: Text(label),
      selected: _currentFilter == filter,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentFilter = filter;
          });
          _applyFilter();
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
  
  Widget _buildParkingSlotsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredSlots.length,
      itemBuilder: (context, index) {
        final slot = _filteredSlots[index];
        return _buildSlotCard(slot);
      },
    );
  }
  
  Widget _buildSlotCard(ParkingSlot slot) {
    // Determinar el color según el estado
    Color statusColor;
    if (slot.isReserved) {
      statusColor = Colors.red.shade100;
    } else if (slot.statusName?.toLowerCase() == 'disponible') {
      statusColor = Colors.green.shade100;
    } else if (slot.statusName?.toLowerCase() == 'mantenimiento') {
      statusColor = Colors.orange.shade100;
    } else {
      statusColor = Colors.grey.shade100;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showSlotDetails(slot),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Espacio ${slot.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slot.isReserved ? 'Reservado' : (slot.statusName ?? 'Desconocido'),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor == Colors.grey.shade100
                            ? Colors.black87
                            : statusColor.withRed(150).withGreen(100).withBlue(100),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              if (slot.propertyName != null)
                Text(
                  'Propiedad: ${slot.propertyName}',
                  style: const TextStyle(fontSize: 14),
                ),
              if (slot.zoneType != null)
                Text(
                  'Zona: ${slot.zoneType}',
                  style: const TextStyle(fontSize: 14),
                ),
              if (slot.tariffType != null)
                Text(
                  'Tarifa: ${slot.tariffType}',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSlotDetails(ParkingSlot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Espacio de Parqueo ${slot.code}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Estado', slot.statusName ?? 'Desconocido'),
              _buildDetailRow('Reservado', slot.isReserved ? 'Sí' : 'No'),
              if (slot.propertyName != null)
                _buildDetailRow('Propiedad', slot.propertyName!),
              if (slot.zoneType != null)
                _buildDetailRow('Tipo de Zona', slot.zoneType!),
              if (slot.tariffType != null)
                _buildDetailRow('Tipo de Tarifa', slot.tariffType!),
              if (slot.tariffAmount != null)
                _buildDetailRow('Monto', '\$${slot.tariffAmount}'),
              if (slot.timeUnit != null)
                _buildDetailRow('Unidad de Tiempo', slot.timeUnit!),
              if (slot.total != null)
                _buildDetailRow('Total', '\$${slot.total}'),
              if (slot.createdAt != null)
                _buildDetailRow('Creado', _formatDate(slot.createdAt!)),
              if (slot.updatedAt != null)
                _buildDetailRow('Actualizado', _formatDate(slot.updatedAt!)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditSlotDialog(context, slot);
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(slot);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  void _showAddSlotDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    bool isReserved = false;
    int statusId = 1; // Por defecto: disponible
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Espacio de Parqueo'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Espacio',
                      hintText: 'Ej: A-01',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un código';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                    ),
                    value: statusId,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Disponible')),
                      DropdownMenuItem(value: 2, child: Text('Ocupado')),
                      DropdownMenuItem(value: 3, child: Text('Mantenimiento')),
                    ],
                    onChanged: (value) {
                      statusId = value ?? 1;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Reservado'),
                    value: isReserved,
                    onChanged: (value) {
                      isReserved = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Crear el nuevo espacio
                  final newSlot = ParkingSlot(
                    id: 0, // El backend asignará el ID real
                    code: codeController.text,
                    parkingZoneId: widget.parkingZoneId!,
                    statusId: statusId,
                    isReserved: isReserved,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
                  final result = await provider.createParkingSlot(newSlot);
                  
                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result
                            ? 'Espacio de parqueo creado con éxito'
                            : 'Error al crear el espacio: ${provider.errorMessage}',
                      ),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditSlotDialog(BuildContext context, ParkingSlot slot) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: slot.code);
    bool isReserved = slot.isReserved;
    int statusId = slot.statusId;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Espacio de Parqueo'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Espacio',
                      hintText: 'Ej: A-01',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un código';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                    ),
                    value: statusId,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Disponible')),
                      DropdownMenuItem(value: 2, child: Text('Ocupado')),
                      DropdownMenuItem(value: 3, child: Text('Mantenimiento')),
                    ],
                    onChanged: (value) {
                      statusId = value ?? statusId;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Reservado'),
                    value: isReserved,
                    onChanged: (value) {
                      isReserved = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Actualizar el espacio
                  final updatedSlot = slot.copyWith(
                    code: codeController.text,
                    statusId: statusId,
                    isReserved: isReserved,
                    updatedAt: DateTime.now(),
                  );
                  
                  final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
                  final result = await provider.updateParkingSlot(updatedSlot);
                  
                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result
                            ? 'Espacio de parqueo actualizado con éxito'
                            : 'Error al actualizar el espacio: ${provider.errorMessage}',
                      ),
                      backgroundColor: result ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
  
  void _confirmDelete(ParkingSlot slot) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Espacio de Parqueo'),
          content: Text('¿Está seguro de eliminar el espacio ${slot.code}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
                final result = await provider.deleteParkingSlot(slot.id);
                
                if (!mounted) return;
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result
                          ? 'Espacio de parqueo eliminado con éxito'
                          : 'Error al eliminar el espacio: ${provider.errorMessage}',
                    ),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}