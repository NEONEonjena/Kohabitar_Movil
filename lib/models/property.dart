class Property {
  final int id;
  final String name;
  final String description;
  final String type;
  final String status;
  final String owner;
  final String address;
  final String observations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.owner,
    required this.address,
    required this.observations,
    this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Se determina si la propiedad está ocupada basado en el estado
    // Esto necesita ajustarse según la estructura real de respuesta de la API
    String status = json['status_name']?.toString().toLowerCase() == 'activo' ||
                    json['status_name']?.toString().toLowerCase() == 'ocupado'
                    ? 'Ocupado' : 'Desocupado';
    
    String observations = status == 'Ocupado' ? '3 pisos' : '2 pisos';
    
    return Property(
      id: json['property_id'] ?? 0,
      name: json['property_name'] ?? '',
      description: json['property_description'] ?? '',
      type: json['property_type'] ?? '',
      status: status,
      owner: 'demo',
      address: 'Casa 10X', 
      observations: observations,
      createdAt: json['property_createAt'] != null ? DateTime.parse(json['property_createAt']) : null,
      updatedAt: json['property_updateAt'] != null ? DateTime.parse(json['property_updateAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': id,
      'property_name': name,
      'property_description': description,
      'property_type': type,
      'property_createAt': createdAt?.toIso8601String(),
      'property_updateAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Property{id: $id, name: $name, type: $type, status: $status, address: $address, owner: $owner, observations: $observations}';
  }
}