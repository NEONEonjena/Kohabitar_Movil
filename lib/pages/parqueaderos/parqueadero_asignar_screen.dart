import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../pages/providers/vehicle_provider.dart';
import '../../providers/propiedad_provider.dart';
import '../../providers/parqueadero_provider.dart';
import '../../widgets/appbar.dart';
import '../../utils/validation_utils.dart';

class ParqueaderoAsignarScreen extends StatefulWidget {
  // Si se recibe un parqueadero, se preselecciona
  final String? parqueaderoSeleccionado;
  
  const ParqueaderoAsignarScreen({
    super.key,
    this.parqueaderoSeleccionado,
  });

  @override
  State<ParqueaderoAsignarScreen> createState() => _ParqueaderoAsignarScreenState();
}

class _ParqueaderoAsignarScreenState extends State<ParqueaderoAsignarScreen> {
  // Valores seleccionados en los dropdowns
  String _propiedadSeleccionada = '';
  String _vehiculoSeleccionado = '';
  String _propietarioSeleccionado = '';
  String? _parqueaderoSeleccionado;
  
  // Clave para el formulario
  final _formKey = GlobalKey<FormState>();
  
  // Indicador para saber si se está enviando el formulario
  bool _isLoading = false;
  
  // Indicador para saber si ya se completó el registro
  bool _registroExitoso = false;
  
  // Datos del vehículo registrado
  String _vehiculoRegistrado = '';
  String _propietarioRegistrado = '';
  String _propiedadRegistrada = '';
  String _parqueaderoRegistrado = '';
  
  @override
  void initState() {
    super.initState();
    
    // Si se recibe un parqueadero, se preselecciona
    _parqueaderoSeleccionado = widget.parqueaderoSeleccionado;
    
    // Se cargan las propiedades, parqueaderos y vehículos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }
  
  // Método para cargar propiedades, parqueaderos y vehículos
  Future<void> _cargarDatos() async {
    final propiedadProvider = Provider.of<PropiedadProvider>(context, listen: false);
    final parqueaderoProvider = Provider.of<ParqueaderoProvider>(context, listen: false);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    
    if (propiedadProvider.propiedades.isEmpty) {
      await propiedadProvider.cargarPropiedades();
    }
    
    if (parqueaderoProvider.parqueaderos.isEmpty) {
      await parqueaderoProvider.cargarParqueaderos();
    }
    
    if (vehicleProvider.vehicles.isEmpty) {
      await vehicleProvider.loadVehicles();
    }
    
    // Si no se tiene una propiedad seleccionada y hay propiedades disponibles, se selecciona la primera
    if (_propiedadSeleccionada.isEmpty && propiedadProvider.propiedades.isNotEmpty) {
      setState(() {
        _propiedadSeleccionada = propiedadProvider.propiedades[0].id;
      });
    }
  }
  
  // Método para actualizar los datos del propietario cuando se selecciona una propiedad
  void _actualizarPropietario(String propiedadId) {
    final propiedadProvider = Provider.of<PropiedadProvider>(context, listen: false);
    final propiedad = propiedadProvider.getPropiedadById(propiedadId);
    
    if (propiedad != null) {
      setState(() {
        _propietarioSeleccionado = propiedad.propietario;
      });
    }
  }
  
  // Método para guardar la asignación
  Future<void> _asignarParqueadero() async {
    // Se valida el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      final parqueaderoProvider = Provider.of<ParqueaderoProvider>(context, listen: false);
      
      // Se obtiene el vehículo seleccionado
      final vehiculo = vehicleProvider.getVehicleById(_vehiculoSeleccionado);
      
      if (vehiculo != null && _parqueaderoSeleccionado != null) {
        // Se asigna el parqueadero al vehículo
        final resultadoVehiculo = await vehicleProvider.assignParkingSlot(
          vehiculo.plate,
          _parqueaderoSeleccionado!,
        );
        
        // Se asigna el vehículo al parqueadero
        final resultadoParqueadero = await parqueaderoProvider.asignarVehiculo(
          _parqueaderoSeleccionado!,
          vehiculo.id,
          _propiedadSeleccionada,
        );
        
        setState(() {
          _isLoading = false;
          
          // Si todo sale bien, se muestra la pantalla de éxito
          if (resultadoVehiculo && resultadoParqueadero) {
            _registroExitoso = true;
            _vehiculoRegistrado = vehiculo.brand;
            _propietarioRegistrado = vehiculo.owner ?? 'Sin propietario';
            _propiedadRegistrada = vehiculo.propertyName ?? 'Sin propiedad';
            _parqueaderoRegistrado = _parqueaderoSeleccionado!;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          // Se muestra mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Datos de vehículo o parqueadero no válidos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // Se muestra mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _registroExitoso ? '' : 'ASIGNAR VEHÍCULO',
        showBackButton: !_registroExitoso,
      ),
      body: _registroExitoso
          ? _buildExitoScreen()
          : _buildFormularioScreen(),
    );
  }
  
  // Pantalla de formulario para asignar vehículo a parqueadero
  Widget _buildFormularioScreen() {
    return Consumer3<PropiedadProvider, ParqueaderoProvider, VehicleProvider>(
      builder: (ctx, propiedadProvider, parqueaderoProvider, vehicleProvider, child) {
        // Si se están cargando los datos, se muestra un indicador de carga
        if (propiedadProvider.isLoading || parqueaderoProvider.isLoading || vehicleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Lista de propiedades disponibles para el dropdown
        final propiedades = propiedadProvider.propiedades;
        
        // Lista de vehículos para la propiedad seleccionada
        List<Vehicle> vehiculosFiltrados = [];
        if (_propiedadSeleccionada.isNotEmpty) {
          vehiculosFiltrados = vehicleProvider.getVehiclesByProperty(_propiedadSeleccionada);
          
          // Si se cambia de propiedad, se reinicia el vehículo seleccionado
          if (_vehiculoSeleccionado.isNotEmpty) {
            final sigueExistiendo = vehiculosFiltrados.any((v) => v.plate == _vehiculoSeleccionado);
            if (!sigueExistiendo) {
              _vehiculoSeleccionado = '';
            }
          }
          
          // Si no se tiene un vehículo seleccionado y hay vehículos disponibles, se selecciona el primero
          if (_vehiculoSeleccionado.isEmpty && vehiculosFiltrados.isNotEmpty) {
            _vehiculoSeleccionado = vehiculosFiltrados[0].plate;
          }
        }
        
        // Lista de parqueaderos libres para el dropdown
        final parqueaderosLibres = parqueaderoProvider.getParqueaderosLibres();
        
        // Si se tiene un parqueadero preseleccionado, se verifica que esté libre
        if (_parqueaderoSeleccionado != null) {
          final parqueaderoSeleccionado = parqueaderoProvider.getParqueaderoById(_parqueaderoSeleccionado!);
          if (parqueaderoSeleccionado != null && parqueaderoSeleccionado.estado.toLowerCase() != 'libre') {
            // Si no está libre, se deselecciona
            _parqueaderoSeleccionado = null;
          }
        }
        
        // Si no se tiene un parqueadero seleccionado y hay parqueaderos libres, se selecciona el primero
        if (_parqueaderoSeleccionado == null && parqueaderosLibres.isNotEmpty) {
          _parqueaderoSeleccionado = parqueaderosLibres[0].id;
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown para seleccionar la propiedad
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Propiedad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  value: propiedades.isNotEmpty && _propiedadSeleccionada.isNotEmpty
                      ? _propiedadSeleccionada
                      : null,
                  items: propiedades.map((propiedad) {
                    return DropdownMenuItem<String>(
                      value: propiedad.id,
                      child: Text(propiedad.id),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _propiedadSeleccionada = value;
                        _actualizarPropietario(value);
                        // Se reinicia el vehículo seleccionado al cambiar de propiedad
                        _vehiculoSeleccionado = '';
                      });
                    }
                  },
                  validator: (value) => ValidationUtils.validarCampoRequerido(value, 'Seleccione una propiedad'),
                ),
                
                const SizedBox(height: 16),
                
                // Dropdown para seleccionar el vehículo
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Marca y Modelo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  value: vehiculosFiltrados.isNotEmpty && _vehiculoSeleccionado.isNotEmpty
                      ? _vehiculoSeleccionado
                      : null,
                  items: vehiculosFiltrados.map((vehiculo) {
                    return DropdownMenuItem<String>(
                      value: vehiculo.plate,
                      child: Text('${vehiculo.brand} ${vehiculo.model}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _vehiculoSeleccionado = value ?? '';
                    });
                  },
                  validator: (value) => ValidationUtils.validarCampoRequerido(value, 'Seleccione un vehículo'),
                ),
                
                const SizedBox(height: 16),
                
                // Campo para mostrar el propietario (no editable)
                TextFormField(
                  readOnly: true,
                  initialValue: _propietarioSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Propietario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Dropdown para seleccionar el parqueadero
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Isla de parqueadero asignado',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_parking),
                  ),
                  value: _parqueaderoSeleccionado,
                  items: parqueaderosLibres.map((parqueadero) {
                    return DropdownMenuItem<String?>(
                      value: parqueadero.id,
                      child: Text(parqueadero.id),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _parqueaderoSeleccionado = value;
                    });
                  },
                  validator: (value) => ValidationUtils.validarCampoRequerido(value, 'Seleccione un parqueadero'),
                ),
                
                const SizedBox(height: 24),
                
                // Botón para guardar la asignación
                ElevatedButton(
                  onPressed: _isLoading || vehiculosFiltrados.isEmpty || parqueaderosLibres.isEmpty
                      ? null
                      : _asignarParqueadero,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'GUARDAR VEHÍCULO',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón para ver vehículos registrados
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'VEHÍCULOS REGISTRADOS',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Pantalla de éxito después de asignar un vehículo
  Widget _buildExitoScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Título e ícono de éxito
          const Text(
            '¡Registro Exitoso!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 80,
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje de éxito
          const Text(
            'El vehículo ha sido registrado correctamente\ny ha sido asignado a la propiedad seleccionada',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 30),
          
          // Resumen del registro
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del registro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildResumenItem('Vehículo:', _vehiculoRegistrado),
                _buildResumenItem('Propietario:', _propietarioRegistrado),
                _buildResumenItem('Propiedad:', _propiedadRegistrada),
                _buildResumenItem('Parqueadero:', _parqueaderoRegistrado),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Botones de acción
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: const Text(
              'VEHÍCULOS REGISTRADOS',
              style: TextStyle(fontSize: 16),
            ),
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: () {
              setState(() {
                _registroExitoso = false;
                _propiedadSeleccionada = '';
                _vehiculoSeleccionado = '';
                _propietarioSeleccionado = '';
                _parqueaderoSeleccionado = null;
                _cargarDatos();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: const Text(
              'REGISTRAR OTRO VEHÍCULO',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para mostrar una fila en el resumen
  Widget _buildResumenItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
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
}