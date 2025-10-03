import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../models/property.dart';
import '../../pages/providers/vehicle_provider.dart';
import '../../pages/providers/property_provider.dart';
import './registered_vehicles_screen.dart';

class AssignVehicleScreen extends StatefulWidget {
  const AssignVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AssignVehicleScreen> createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final _propertyController = TextEditingController();
  final _brandModelController = TextEditingController();
  final _ownerController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Carga las propiedades después de construir el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties();
    });
  }

  Future<void> _loadProperties() async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    await propertyProvider.loadProperties();
  }

  @override
  void dispose() {
    _propertyController.dispose();
    _brandModelController.dispose();
    _ownerController.dispose();
    _parkingSlotController.dispose();
    super.dispose();
  }

  // Diálogo para seleccionar una propiedad
  Future<void> _selectProperty() async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
    // Si las propiedades no se han cargado todavía, se cargan
    if (propertyProvider.properties.isEmpty && !propertyProvider.isLoading) {
      await propertyProvider.loadProperties();
    }
    
    if (!mounted) return;
    
    final selectedProperty = await showDialog<Property>(
      context: context,
      builder: (context) => _buildPropertySelectionDialog(propertyProvider.properties),
    );
    
    if (selectedProperty != null) {
      setState(() {
        _propertyController.text = selectedProperty.name;
      });
    }
  }
  
  // Construye el diálogo de selección de propiedad
  Widget _buildPropertySelectionDialog(List<Property> properties) {
    return AlertDialog(
      title: const Text('Seleccionar Propiedad'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return ListTile(
              title: Text(property.name),
              subtitle: Text(property.address),
              onTap: () {
                Navigator.of(context).pop(property);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
  
  // Diálogo para seleccionar marca y modelo
  Future<void> _selectBrandModel() async {
    final brandModel = await showDialog<String>(
      context: context,
      builder: (context) => _buildBrandModelSelectionDialog(),
    );
    
    if (brandModel != null) {
      setState(() {
        _brandModelController.text = brandModel;
      });
    }
  }
  
  // Construye el diálogo de selección de marca y modelo
  Widget _buildBrandModelSelectionDialog() {
    // Obtenemos los modelos desde la API a través del provider
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    final vehicles = vehicleProvider.vehicles;
    final models = vehicles.map((v) => v.brandModel ?? '${v.brand} ${v.model}').toSet().toList();
    
    // Si no hay datos, mostramos algunos valores por defecto
    if (models.isEmpty) {
      models.add('Agregar un modelo nuevo');
    }
    
    return AlertDialog(
      title: const Text('Seleccionar Marca y Modelo'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: models.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(models[index]),
              onTap: () {
                Navigator.of(context).pop(models[index]);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
  
  // Diálogo para seleccionar propietario
  Future<void> _selectOwner() async {
    final owner = await showDialog<String>(
      context: context,
      builder: (context) => _buildOwnerSelectionDialog(),
    );
    
    if (owner != null) {
      setState(() {
        _ownerController.text = owner;
      });
    }
  }
  
  // Construye el diálogo de selección de propietario
  Widget _buildOwnerSelectionDialog() {
    // Obtenemos los propietarios desde la API a través del provider
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    final vehicles = vehicleProvider.vehicles;
    final owners = vehicles
        .map((v) => v.owner)
        .where((owner) => owner != null && owner.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();
    
    // Si no hay datos, mostramos algunos valores por defecto
    if (owners.isEmpty) {
      owners.add('Agregar un propietario nuevo');
    }
    
    return AlertDialog(
      title: const Text('Seleccionar Propietario'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: owners.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(owners[index]),
              onTap: () {
                Navigator.of(context).pop(owners[index]);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Separa la marca y el modelo
      final brandModelParts = _brandModelController.text.split(' ');
      final brand = brandModelParts.isNotEmpty ? brandModelParts[0] : '';
      final model = brandModelParts.length > 1 ? brandModelParts.sublist(1).join(' ') : '';
      
      final vehicle = Vehicle(
        plate: _parkingSlotController.text,
        brand: brand,
        model: model,
        color: 'N/A', // No se muestra en el mockup, pero es requerido por el modelo
        parkingSlot: _parkingSlotController.text,
        propertyName: _propertyController.text,
      );
      
      final success = await Provider.of<VehicleProvider>(context, listen: false).createVehicle(vehicle);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '¡Vehículo guardado exitosamente!' : 'Error al guardar el vehículo'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        // Navega a la pantalla de vehículos registrados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisteredVehiclesScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar el vehículo: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASIGNAR VEHÍCULO'),
        backgroundColor: const Color(0xFF05877C),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo de selección de propiedad
                    const SizedBox(height: 16),
                    const Text(
                      'Propiedad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectField(
                      controller: _propertyController,
                      hintText: 'Seleccionar propiedad',
                      onTap: _selectProperty,
                    ),
                    
                    // Campo de selección de marca y modelo
                    const SizedBox(height: 20),
                    const Text(
                      'Marca y Modelo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectField(
                      controller: _brandModelController,
                      hintText: 'Seleccionar marca y modelo',
                      onTap: _selectBrandModel,
                    ),
                    
                    // Campo de selección de propietario
                    const SizedBox(height: 20),
                    const Text(
                      'Propietario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSelectField(
                      controller: _ownerController,
                      hintText: 'Seleccionar propietario',
                      onTap: _selectOwner,
                    ),
                    
                    // Campo para ingreso de isla de parqueadero
                    const SizedBox(height: 20),
                    const Text(
                      'Isla de parqueadero asignado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _parkingSlotController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese código de parqueadero',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el código del parqueadero';
                        }
                        return null;
                      },
                    ),
                    
                    // Mensaje de error si existe
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    
                    // Botón para guardar vehículo
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05877C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveVehicle,
                      child: const Text(
                        'GUARDAR VEHÍCULO',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    // Botón para ver vehículos registrados
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisteredVehiclesScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'VEHÍCULOS REGISTRADOS',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  // Método auxiliar para construir campos de selección
  Widget _buildSelectField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ),
    );
  }
}