class Visitor {
  final int id;
  final String name;
  final String? documentId;
  final String? purpose;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final int? propertyId;
  final String? propertyName;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Visitor({
    required this.id,
    required this.name,
    this.documentId,
    this.purpose,
    this.entryTime,
    this.exitTime,
    this.propertyId,
    this.propertyName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['visitor_id'] ?? 0,
      name: json['name'] ?? '',
      documentId: json['document_id'],
      purpose: json['purpose'],
      entryTime: json['entry_time'] != null ? DateTime.parse(json['entry_time']) : null,
      exitTime: json['exit_time'] != null ? DateTime.parse(json['exit_time']) : null,
      propertyId: json['property_id'],
      propertyName: json['property_name'],
      status: json['status_name'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitor_id': id,
      'name': name,
      'document_id': documentId,
      'purpose': purpose,
      'entry_time': entryTime?.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'property_id': propertyId,
      'property_name': propertyName,
      'status_name': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Visitor{id: $id, name: $name, documentId: $documentId, purpose: $purpose, propertyName: $propertyName}';
  }
}