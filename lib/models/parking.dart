class Parking {
  final int id;
  final String name;
  final String? description;
  final String? status;
  final int? property;
  final String? propertyName;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Parking({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.property,
    this.propertyName,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['parking_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status_name'],
      property: json['property_id'],
      propertyName: json['property_name'],
      location: json['location'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking_id': id,
      'name': name,
      'description': description,
      'status_name': status,
      'property_id': property,
      'property_name': propertyName,
      'location': location,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Parking{id: $id, name: $name, status: $status, propertyName: $propertyName, location: $location}';
  }
}