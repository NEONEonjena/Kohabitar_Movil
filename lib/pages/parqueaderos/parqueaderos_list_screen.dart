import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/parqueadero_model.dart';
import '../../providers/parqueadero_provider.dart';
import '../../providers/vehiculo_provider.dart';
import '../../widgets/appbar.dart';
import 'parqueadero_asignar_screen.dart';

class ParqueaderosListScreen extends StatefulWidget {
  const ParqueaderosListScreen({super.key});

  @override
  State<ParqueaderosListScreen> createState() => _ParqueaderosListScreenState();
}

class _ParqueaderosListScreenState extends State<ParqueaderosListScreen> {
  // Flag para mostrar todos los parqueaderos o filtrar
  bool _mostrarTodos = true;
  bool _mostrarOcupados = false;
  bool _mostrarLibres = false;

  // Función para refrescar la lista de parqueaderos
  Future<void> _refreshParqueaderos() async {
    await Provider.of<ParqueaderoProvider>(context, listen: false).cargarParqueaderos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'PARQUEADEROS',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    selected: _mostrarTodos,
                    onSelected: (selected) {
                      setState(() {
                        _mostrarTodos = selected;
                        if (selected) {
                          _mostrarOcupados = false;
                          _mostrarLibres = false;
                        } else if (!_mostrarOcupados && !_mostrarLibres) {
                          _mostrarTodos = true;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Ocupados',
                    selected: _mostrarOcupados,
                    onSelected: (selected) {
                      setState(() {
                        _mostrarOcupados = selected;
                        if (selected) {
                          _mostrarTodos = false;
                          _mostrarLibres = false;
                        } else if (!_mostrarTodos && !_mostrarLibres) {
                          _mostrarTodos = true;
                        }
                      });
                    },
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Libres',
                    selected: _mostrarLibres,
                    onSelected: (selected) {
                      setState(() {
                        _mostrarLibres = selected;
                        if (selected) {
                          _mostrarTodos = false;
                          _mostrarOcupados = false;
                        } else if (!_mostrarTodos && !_mostrarOcupados) {
                          _mostrarTodos = true;
                        }
                      });
                    },
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de parqueaderos
          Expanded(
            child: Consumer2<ParqueaderoProvider, VehiculoProvider>(
              builder: (ctx, parqueaderoProvider, vehiculoProvider, child) {
                if (parqueaderoProvider.isLoading) {
                  // Mostrar indicador de carga si está cargando
                  return const Center(child: CircularProgressIndicator());
                }

                if (parqueaderoProvider.hasError) {
                  // Mostrar mensaje de error si hay un error
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(
                          'Error: ${parqueaderoProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshParqueaderos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar los parqueaderos según los filtros seleccionados
                List<Parqueadero> parqueaderosFiltrados = [];
                
                if (_mostrarTodos) {
                  parqueaderosFiltrados = parqueaderoProvider.parqueaderos;
                } else if (_mostrarOcupados) {
                  parqueaderosFiltrados = parqueaderoProvider.getParqueaderosOcupados();
                } else if (_mostrarLibres) {
                  parqueaderosFiltrados = parqueaderoProvider.getParqueaderosLibres();
                }

                if (parqueaderosFiltrados.isEmpty) {
                  // Mostrar mensaje si no hay parqueaderos
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_parking,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _mostrarTodos
                              ? 'No hay parqueaderos registrados'
                              : _mostrarOcupados
                                  ? 'No hay parqueaderos ocupados'
                                  : 'No hay parqueaderos libres',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _mostrarTodos = true;
                              _mostrarOcupados = false;
                              _mostrarLibres = false;
                            });
                          },
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ),
                  );
                }

                // Mostrar la lista de parqueaderos
                return RefreshIndicator(
                  onRefresh: _refreshParqueaderos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: parqueaderosFiltrados.length,
                    itemBuilder: (ctx, i) {
                      final parqueadero = parqueaderosFiltrados[i];
                      
                      // Obtener el vehículo asignado (si existe)
                      final vehiculo = parqueadero.vehiculoId != null
                          ? vehiculoProvider.getVehiculoById(parqueadero.vehiculoId!)
                          : null;
                      
                      return _buildParqueaderoCard(
                        parqueadero, 
                        vehiculo?.marca ?? 'No asignado',
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para asignar un parqueadero
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ParqueaderoAsignarScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('ASIGNAR'),
      ),
    );
  }
  
  // Widget para crear un chip de filtro
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: color ?? Theme.of(context).primaryColor.withOpacity(0.3),
      checkmarkColor: color != null ? Colors.white : Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? (color != null ? Colors.white : Theme.of(context).primaryColor) : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // Widget para mostrar la tarjeta de un parqueadero
  Widget _buildParqueaderoCard(Parqueadero parqueadero, String vehiculoNombre) {
    // Determinar colores según el estado del parqueadero
    final bool estaOcupado = parqueadero.estaOcupado();
    final Color backgroundColor = estaOcupado ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);
    final Color borderColor = estaOcupado ? Colors.red : Colors.green;
    final Color textColor = estaOcupado ? Colors.red[700]! : Colors.green[700]!;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          // Mostrar diálogo con opciones
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildActionSheet(parqueadero),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icono de parqueadero
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: estaOcupado ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  estaOcupado ? Icons.car_rental : Icons.local_parking,
                  color: textColor,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del parqueadero
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parqueadero.id,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado: ${parqueadero.estado}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (parqueadero.vehiculoId != null)
                      Text(
                        'Vehículo: $vehiculoNombre',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (parqueadero.propiedadId != null)
                      Text(
                        'Propiedad: ${parqueadero.propiedadId!}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
              
              // Flecha para indicar que hay más opciones
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget para crear la hoja de acciones para un parqueadero
  Widget _buildActionSheet(Parqueadero parqueadero) {
    final parqueaderoProvider = Provider.of<ParqueaderoProvider>(context, listen: false);
    final bool estaOcupado = parqueadero.estaOcupado();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Parqueadero ${parqueadero.id}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Estado: ${parqueadero.estado}',
            style: TextStyle(
              color: estaOcupado ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          if (estaOcupado)
            ElevatedButton.icon(
              icon: const Icon(Icons.car_rental_outlined),
              label: const Text('LIBERAR PARQUEADERO'),
              onPressed: () async {
                // Cerrar la hoja de acciones
                Navigator.pop(context);
                
                // Confirmar la liberación
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Liberar Parqueadero'),
                    content: const Text(
                      '¿Está seguro que desea liberar este parqueadero? '
                      'Esto eliminará la asignación del vehículo actual.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('CANCELAR'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('LIBERAR'),
                      ),
                    ],
                  ),
                );
                
                if (confirmar == true) {
                  // Liberar el parqueadero
                  final resultado = await parqueaderoProvider.liberarParqueadero(parqueadero.id);
                  
                  if (resultado && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Parqueadero liberado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al liberar el parqueadero'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          else
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('ASIGNAR VEHÍCULO'),
              onPressed: () {
                // Cerrar la hoja de acciones
                Navigator.pop(context);
                
                // Navegar a la pantalla de asignación de vehículos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParqueaderoAsignarScreen(
                      parqueaderoSeleccionado: parqueadero.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          
          const SizedBox(height: 8),
          
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('CERRAR'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}