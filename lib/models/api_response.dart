/**
 * ApiResponse
 * 
 * Clase genérica que encapsula todas las respuestas de la API en un formato estandarizado.
 * Permite manejar tanto respuestas exitosas como errores de manera consistente.
 * 
 * Esta clase es fundamental en la arquitectura de comunicación con la API,
 * ya que proporciona una estructura unificada para todas las respuestas,
 * independientemente del endpoint o la operación realizada.
 */
class ApiResponse<T> {
  final T? data;            // Datos de la respuesta (tipo genérico)
  final bool success;       // Indica si la solicitud fue exitosa
  final String? message;    // Mensaje informativo o de error
  final int? statusCode;    // Código de estado HTTP

  /**
   * Constructor principal
   * 
   * @param data Datos de la respuesta (opcional)
   * @param success Indica si la solicitud fue exitosa
   * @param message Mensaje informativo o de error (opcional)
   * @param statusCode Código de estado HTTP (opcional)
   */
  ApiResponse({
    this.data,
    required this.success,
    this.message,
    this.statusCode,
  });

  /**
   * Constructor factory para respuestas exitosas
   * 
   * @param data Datos de la respuesta
   * @return Una nueva instancia de ApiResponse con éxito
   */
  factory ApiResponse.success(T data) {
    return ApiResponse(
      data: data,
      success: true,
      statusCode: 200,
    );
  }

  /**
   * Constructor factory para respuestas de error
   * 
   * @param message Mensaje de error
   * @param statusCode Código de estado HTTP (opcional)
   * @return Una nueva instancia de ApiResponse con error
   */
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  /**
   * Representación en texto de esta instancia para depuración
   */
  @override
  String toString() => 'ApiResponse{data: $data, success: $success, message: $message, statusCode: $statusCode}';
}