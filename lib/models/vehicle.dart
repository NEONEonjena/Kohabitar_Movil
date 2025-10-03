class Vehicle {
  final String plate;
  final String brand;
  final String model;
  final String color;
  final String? parkingSlot;
  final String? propertyName;
  final String? owner;
  final String? brandModel; // Combinación de marca y modelo para mostrar en la interfaz

  Vehicle({
    required this.plate,
    required this.brand,
    required this.model,
    required this.color,
    this.parkingSlot,
    this.propertyName,
    this.owner,
    String? brandModel,
  }) : brandModel = brandModel ?? '$brand $model';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final brand = json['model'] ?? ''; // En la API, la información de marca está en el campo model
    final model = json['type'] ?? '';
    
    return Vehicle(
      plate: json['license_plate'] ?? '',
      brand: brand,
      model: model,
      color: json['color'] ?? '',
      parkingSlot: json['parkingSlot_code'],
      propertyName: json['property_name'],
      owner: json['owner_name'],
      brandModel: '$brand $model',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_plate': plate,
      'model': brand,
      'type': model,
      'color': color,
      'parkingSlot_code': parkingSlot,
      'property_name': propertyName,
      'owner_name': owner,
    };
  }
}
