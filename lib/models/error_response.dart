class ErrorResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final List<String>? errors;

  ErrorResponse({
    this.success,
    this.message,
    this.statusCode,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    List<String>? errors;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errors = List<String>.from(json['errors'].map((e) => e.toString()));
      } else if (json['errors'] is Map) {
        errors = [];
        (json['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errors!.addAll(List<String>.from(value.map((e) => e.toString())));
          } else {
            errors!.add(value.toString());
          }
        });
      }
    }

    return ErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Error desconocido',
      statusCode: json['statusCode'] ?? 500,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ErrorResponse{success: $success, message: $message, statusCode: $statusCode, errors: $errors}';
  }
}