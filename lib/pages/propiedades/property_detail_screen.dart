import 'package:flutter/material.dart';
import '../../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    // Check if the property is occupied to determine styling
    final bool isOccupied = property.status == 'Ocupado';
    final String statusText = isOccupied ? 'Ocupado' : 'Libre';

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name.toUpperCase()),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D7B),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image/banner
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Banner background
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D7B),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isOccupied ? Icons.home : Icons.home_outlined,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
                
                // Status badge
                Positioned(
                  bottom: -20,
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isOccupied ? Colors.green.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  child: Center(
                    child: Text(
                      statusText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOccupied ? Colors.green.shade800 : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Property details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property title and type
                  Text(
                    property.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D7B),
                    ),
                  ),
                  Text(
                    property.type,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Property information
                  _buildInfoSection(
                    'Información de la propiedad', 
                    [
                      _buildInfoItem(Icons.person, 'Propietario', property.owner),
                      _buildInfoItem(Icons.location_on, 'Dirección', property.address),
                      _buildInfoItem(Icons.description, 'Observaciones', property.observations),
                    ]
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description section
                  _buildInfoSection(
                    'Descripción', 
                    [
                      _buildDescriptionItem(property.description),
                    ]
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Edit action
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('EDITAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('FINALIZAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D7B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D7B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D7B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String description) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        description.isNotEmpty ? description : 'Sin descripción',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          height: 1.5,
        ),
      ),
    );
  }
}