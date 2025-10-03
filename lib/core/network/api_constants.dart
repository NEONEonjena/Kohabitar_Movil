/**
 * Clase ApiConstants
 * 
 * Esta clase define todas las constantes relacionadas con la API REST.
 * Aquí se centraliza la configuración de:
 * - URL base de la API
 * - Versión de la API
 * - Endpoints para cada recurso
 * - Tiempos de espera para conexiones HTTP
 * 
 * Al tener estas constantes centralizadas, es fácil cambiar la configuración
 * de la API en un solo lugar, por ejemplo, al migrar de desarrollo local a producción.
 */
class ApiConstants {
  // URL base de la API (localhost para entornos de desarrollo local)
  static const String baseUrl = 'http://localhost:3000';

  // Versión actual de la API
  static const String apiVersion = '/api_v1';

  // Endpoints definidos para cada recurso
  static const String login = '$apiVersion/auth/login';
  static const String users = '$apiVersion/users';
  static const String amenities = '$apiVersion/amenity';
  static const String properties =
      '$apiVersion/property'; // Corregido de properties a property
  static const String parkings = '$apiVersion/parkings';
  static const String parkingSlots = '$apiVersion/parkingslot';
  static const String visitors = '$apiVersion/visitors';

  // Tiempos máximos de espera para conexiones HTTP (en milisegundos)
  static const int connectTimeout =
      15000; // 15 segundos para establecer conexión
  static const int receiveTimeout =
      15000; // 15 segundos para recibir la respuesta
}
