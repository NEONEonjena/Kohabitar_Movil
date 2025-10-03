import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property.dart';
import '../providers/property_provider.dart';
import '../providers/auth_provider.dart';
import 'property_detail_screen.dart';
import '../../widgets/navigation_drawer.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late PropertyProvider _propertyProvider;
  @override
  void initState() {
    super.initState();
    // Access the provider after the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      _loadProperties();
    });
  }

  Future<void> _loadProperties() async {
    await _propertyProvider.loadProperties();
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _propertyProvider.applyFilter(filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text('PROPIEDADES'),
            centerTitle: true,
            backgroundColor: const Color(0xFF2E7D7B),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Notifications action
                },
              ),
            ],
          ),
          drawer: Consumer<AuthProvider>(
            builder: (context, authProvider, _) => CustomDrawer(
              username: authProvider.name ?? authProvider.username ?? "Usuario", // Dynamic username from auth provider
              currentIndex: 1, // assuming properties is index 1
              onItemSelected: (index) {
                Navigator.pop(context);
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/zonas');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/propiedades');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/clientes');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/configuraciones');
                }
              },
              onLogout: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          body: Column(
            children: [
              // Filter buttons
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton('todas', 'TODAS', propertyProvider.currentFilter == 'todas'),
                    _buildFilterButton('activas', 'OCUPADAS', propertyProvider.currentFilter == 'activas'),
                    _buildFilterButton('inactivas', 'LIBRES', propertyProvider.currentFilter == 'inactivas'),
                  ],
                ),
              ),
              
              // Property count and refresh button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${propertyProvider.filteredProperties.length} propiedades',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF2E7D7B)),
                      onPressed: _loadProperties,
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: propertyProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFF2E7D7B),
                    ))
                  : propertyProvider.errorMessage != null
                      ? _buildErrorWidget(propertyProvider)
                      : _buildPropertyList(),
              ),
            ],
          ),
        );
      }
    );
  }
  
  Widget _buildFilterButton(String value, String label, bool isSelected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _applyFilter(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF1B4B49) : const Color(0xFF4A9B99),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(PropertyProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              provider.errorMessage ?? 'Ocurrió un error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          if (provider.errorMessage?.contains('Endpoint') ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Verifique que la API esté corriendo en http://localhost:3000 y que las rutas estén configuradas correctamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProperties,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D7B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList() {
    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: _loadProperties,
          child: provider.filteredProperties.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = provider.filteredProperties[index];
                    return _buildPropertyCard(property);
                  },
                ),
        );
      }
    );
  }
  
  Widget _buildEmptyState() {
    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                provider.currentFilter == 'todas'
                    ? 'No hay propiedades disponibles'
                    : provider.currentFilter == 'activas'
                        ? 'No hay propiedades ocupadas'
                        : 'No hay propiedades libres',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Check the property status to apply different styling
    final bool isOccupied = property.status == 'Ocupado';
    final String statusText = isOccupied ? 'OCUPADO' : 'LIBRE';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/property-detail',
              arguments: {'property': property},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // House Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D7B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Color(0xFF2E7D7B),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Property details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D7B),
                        ),
                      ),
                      Text(
                        'Propietario: ${property.owner}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Observación: ${property.observations}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOccupied ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOccupied ? Colors.green.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}