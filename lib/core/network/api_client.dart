/**
 * API Client
 * 
 * El cliente API facilita la comunicación con el servidor.
 * Proporciona métodos básicos para realizar peticiones HTTP y
 * gestiona las respuestas de forma estandarizada.
 * 
 * Características:
 * - Implementa métodos HTTP básicos (GET, POST, PUT, DELETE)
 * - Gestiona autenticación con tokens JWT
 * - Maneja errores de forma básica
 * - Incluye comentarios explicativos para cada parte
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

// Clase que maneja las respuestas de la API de forma estandarizada
class ApiResponse<T> {
  // Datos devueltos por la API (si la respuesta fue exitosa)
  final T? data;

  // Mensaje informativo o de error
  final String? message;

  // Indica si la petición fue exitosa
  final bool success;

  // Código de estado HTTP (opcional)
  final int? statusCode;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  // Constructor para respuestas exitosas
  ApiResponse.success(this.data)
      : success = true,
        message = 'Éxito',
        statusCode = 200;

  // Constructor para respuestas con error
  ApiResponse.error(this.message, {this.statusCode})
      : success = false,
        data = null;
}

// Cliente API para la comunicación con el servidor
class ApiClient {
  // URL base de la API
  final String baseUrl = ApiConstants.baseUrl;

  // Patrón Singleton: asegura una única instancia en toda la aplicación
  static final ApiClient _instance = ApiClient._internal();

  // Cliente HTTP que realiza las peticiones
  final http.Client _httpClient;

  /**
   * Constructor factory que devuelve la instancia singleton
   */
  factory ApiClient() => _instance;

  /**
   * Constructor privado que inicializa el cliente HTTP
   */
  ApiClient._internal() : _httpClient = http.Client();

  /**
   * Constructor especial para pruebas unitarias
   * Permite inyectar un cliente HTTP simulado para pruebas
   */
  ApiClient.test(this._httpClient);

  // Obtiene el token de autenticación almacenado en el dispositivo local
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Crea los encabezados HTTP necesarios para las peticiones a la API
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    // Prepara los encabezados básicos
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Agrega el token de autenticación cuando es requerido
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Método GET que obtiene datos del servidor
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      // Construye la URL con parámetros de consulta si existen
      final uri =
          Uri.parse(baseUrl + endpoint).replace(queryParameters: queryParams);

      // Obtiene los encabezados HTTP necesarios
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Realiza la petición GET al servidor
      debugPrint('GET: $uri');
      final response = await _httpClient.get(uri, headers: headers);

      // Procesa la respuesta recibida
      return _processResponse(response, fromJson);
    } catch (e) {
      // Maneja cualquier error producido
      debugPrint('Error en GET: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Método POST que envía datos al servidor
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Construye la URL para la petición
      final uri = Uri.parse(baseUrl + endpoint);

      // Obtiene los encabezados HTTP necesarios
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Convierte el cuerpo a formato JSON si existe
      final jsonBody = body != null ? json.encode(body) : null;

      // Realiza la petición POST al servidor
      debugPrint('POST: $uri');
      debugPrint('Body: $jsonBody');
      final response =
          await _httpClient.post(uri, headers: headers, body: jsonBody);

      // Procesa la respuesta recibida
      return _processResponse(response, fromJson);
    } catch (e) {
      // Maneja cualquier error producido
      debugPrint('Error en POST: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Método PUT que actualiza datos existentes en el servidor
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Construye la URL para la petición
      final uri = Uri.parse(baseUrl + endpoint);

      // Obtiene los encabezados HTTP necesarios
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Convierte el cuerpo a formato JSON si existe
      final jsonBody = body != null ? json.encode(body) : null;

      // Realiza la petición PUT al servidor
      debugPrint('PUT: $uri');
      debugPrint('Body: $jsonBody');
      final response =
          await _httpClient.put(uri, headers: headers, body: jsonBody);

      // Procesa la respuesta recibida
      return _processResponse(response, fromJson);
    } catch (e) {
      // Maneja cualquier error producido
      debugPrint('Error en PUT: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Método DELETE que elimina datos del servidor
  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Construye la URL para la petición
      final uri = Uri.parse(baseUrl + endpoint);

      // Obtiene los encabezados HTTP necesarios
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Convierte el cuerpo a formato JSON si existe
      final jsonBody = body != null ? json.encode(body) : null;

      // Realiza la petición DELETE al servidor
      debugPrint('DELETE: $uri');
      final response =
          await _httpClient.delete(uri, headers: headers, body: jsonBody);

      // Procesa la respuesta recibida
      return _processResponse(response, fromJson);
    } catch (e) {
      // Maneja cualquier error producido
      debugPrint('Error en DELETE: $e');
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  // Procesa la respuesta HTTP y la convierte en un objeto ApiResponse
  ApiResponse<T> _processResponse<T>(
      http.Response response, T Function(Map<String, dynamic>) fromJson) {
    // Imprime información de la respuesta para depuración
    debugPrint('RESPONSE: ${response.statusCode}');
    debugPrint(
        'Body: ${response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body}');

    // Manejo especial para el mensaje "Endpoint losses" (404 Not Found)
    if (response.statusCode == 404 &&
        response.body.contains('Endpoint losses')) {
      return ApiResponse.error(
          'La ruta de API solicitada no existe. Verifique la URL del endpoint.',
          statusCode: response.statusCode);
    }

    // Verifica si la respuesta es exitosa (códigos 2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Decodifica el cuerpo de la respuesta JSON
        final jsonData = json.decode(response.body);

        // Maneja formato de respuesta estándar {success, data, message}
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('success')) {
          if (jsonData['success'] == true) {
            // Respuesta exitosa con datos
            final data = fromJson(jsonData);
            return ApiResponse.success(data);
          } else {
            // Respuesta con error del servidor
            final message =
                jsonData['message'] ?? 'Error en la respuesta del servidor';
            return ApiResponse.error(message, statusCode: response.statusCode);
          }
        } else if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('message')) {
          // Maneja respuesta API estándar con mensaje
          final data = fromJson(jsonData);
          return ApiResponse.success(data);
        }

        // Para respuestas que no siguen el formato estándar
        final data = fromJson(jsonData);
        return ApiResponse.success(data);
      } catch (e) {
        // Error al procesar el JSON
        return ApiResponse.error('Error al procesar la respuesta: $e');
      }
    } else {
      // Respuesta con error HTTP (4xx, 5xx)
      String errorMessage;
      try {
        // Intenta obtener mensaje de error del servidor
        final errorData = json.decode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Error del servidor';
      } catch (_) {
        // Si no hay mensaje de error válido
        if (response.statusCode == 404) {
          errorMessage =
              'Recurso no encontrado (404). Verifique la URL del endpoint.';
        } else if (response.statusCode == 500) {
          errorMessage =
              'Error interno del servidor (500). Contacte al administrador.';
        } else {
          errorMessage = 'Error del servidor (${response.statusCode})';
        }
      }
      return ApiResponse.error(errorMessage, statusCode: response.statusCode);
    }
  }

  // Libera los recursos cuando no se necesita más el cliente
  void dispose() {
    _httpClient.close();
  }
}
