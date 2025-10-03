/// Modelo ParkingSlot
/// 
/// Esta clase representa un espacio específico de parqueo dentro de una zona.
/// Contiene información sobre su código, estado, tarifas y otros detalles relevantes.
library;

class ParkingSlot {
  final int id;
  final String code;
  final int parkingZoneId;
  final String? zoneType;
  final int? zoneCapacity;
  final String? propertyName;
  final int statusId;
  final String? statusName;
  final bool isReserved;
  final String? timeUnit;
  final double? total;
  final int? tariffId;
  final String? tariffType;
  final double? tariffAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParkingSlot({
    required this.id,
    required this.code,
    required this.parkingZoneId,
    this.zoneType,
    this.zoneCapacity,
    this.propertyName,
    required this.statusId,
    this.statusName,
    required this.isReserved,
    this.timeUnit,
    this.total,
    this.tariffId,
    this.tariffType,
    this.tariffAmount,
    this.createdAt,
    this.updatedAt,
  });

  // Constructor factory que crea un objeto ParkingSlot desde un mapa JSON
  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    // Depuración
    print('Analizando JSON de ParkingSlot: $json');
    
    return ParkingSlot(
      id: json['parkingSlot_id'] ?? 0,
      code: json['code'] ?? '',
      parkingZoneId: json['parkingZone_id'] ?? 0,
      zoneType: json['zone_type'],
      zoneCapacity: json['zone_capacity'],
      propertyName: json['property_name'],
      statusId: json['status_id'] ?? 1,
      statusName: json['status_name'],
      isReserved: json['is_reserved'] == 1 || json['is_reserved'] == true,
      timeUnit: json['time_unit'],
      total: json['total'] != null ? double.tryParse(json['total'].toString()) : null,
      tariffId: json['tariff_id'],
      tariffType: json['tariff_type'],
      tariffAmount: json['tariff_amount'] != null ? double.tryParse(json['tariff_amount'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  // Convierte este objeto a un mapa JSON para su envío al servidor
  Map<String, dynamic> toJson() {
    return {
      'parkingSlot_id': id,
      'code': code,
      'parkingZone_id': parkingZoneId,
      'status_id': statusId,
      'is_reserved': isReserved ? 1 : 0,
      'time_unit': timeUnit,
      'total': total,
      'tariff_id': tariffId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ParkingSlot{id: $id, code: $code, status: $statusName, isReserved: $isReserved}';
  }

  // Crea una copia nueva del objeto con los campos especificados actualizados
  ParkingSlot copyWith({
    int? id,
    String? code,
    int? parkingZoneId,
    String? zoneType,
    int? zoneCapacity,
    String? propertyName,
    int? statusId,
    String? statusName,
    bool? isReserved,
    String? timeUnit,
    double? total,
    int? tariffId,
    String? tariffType,
    double? tariffAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSlot(
      id: id ?? this.id,
      code: code ?? this.code,
      parkingZoneId: parkingZoneId ?? this.parkingZoneId,
      zoneType: zoneType ?? this.zoneType,
      zoneCapacity: zoneCapacity ?? this.zoneCapacity,
      propertyName: propertyName ?? this.propertyName,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      isReserved: isReserved ?? this.isReserved,
      timeUnit: timeUnit ?? this.timeUnit,
      total: total ?? this.total,
      tariffId: tariffId ?? this.tariffId,
      tariffType: tariffType ?? this.tariffType,
      tariffAmount: tariffAmount ?? this.tariffAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}