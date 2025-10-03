/**
 * Clase Amenity (Zona Común)
 * 
 * Esta clase representa el modelo de datos para las zonas comunes en la aplicación.
 * Implementa:
 * - Propiedades inmutables (final) para garantizar la integridad de los datos
 * - Método factory para crear instancias desde JSON
 * - Método para convertir la instancia a JSON
 * - Override de toString() para depuración
 * 
 * Este modelo mapea directamente a la entidad 'amenity' en la API REST.
 */
class Amenity {
  // Propiedades del modelo
  final int id; // ID único de la zona común
  final String name; // Nombre de la zona común
  final String? description; // Descripción (opcional)
  final String? status; // Estado actual (activo, inactivo, etc.)
  final double? capacity; // Capacidad máxima (opcional)
  final bool isAvailable; // Indica si está disponible para reservas
  final DateTime? createdAt; // Fecha de creación
  final DateTime? updatedAt; // Fecha de última actualización

  // Constructor
  Amenity({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.capacity,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  /**
   * Crea una instancia de Amenity a partir de un mapa JSON
   * 
   * @param json Mapa con los datos del JSON recibido de la API
   * @return Una nueva instancia de Amenity con los datos del JSON
   */
  factory Amenity.fromJson(Map<String, dynamic> json) {
    // Determinar si la zona común está disponible basado en su estado
    final status = json['status_name'] ?? '';
    final isAvailable = status.toLowerCase() == 'activo' ||
        status.toLowerCase() == 'available' ||
        status.toLowerCase() == 'disponible';

    return Amenity(
      id: json['amenity_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      status: status,
      // Convertir capacity a double si existe
      capacity: json['capacity'] != null
          ? double.parse(json['capacity'].toString())
          : null,
      isAvailable: isAvailable,
      // Parsear fechas si existen
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /**
   * Convierte esta instancia a un mapa JSON
   * 
   * @return Mapa con los datos de esta instancia listos para ser enviados a la API
   */
  Map<String, dynamic> toJson() {
    return {
      'amenity_id': id,
      'name': name,
      'description': description,
      'status_name': status,
      'capacity': capacity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /**
   * Representación en texto de esta instancia para depuración
   */
  @override
  String toString() {
    return 'Amenity{id: $id, name: $name, description: $description, status: $status, isAvailable: $isAvailable}';
  }
}
