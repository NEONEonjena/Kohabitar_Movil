import '../models/visitor.dart';
import '../services/visitor_service.dart';

class VisitorRepository {
  final VisitorService _visitorService;
  
  VisitorRepository({VisitorService? visitorService}) 
      : _visitorService = visitorService ?? VisitorService();
  
  // Obtener todos los visitantes
  Future<List<Visitor>> getAllVisitors() async {
    try {
      final response = await _visitorService.getVisitors();
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener visitantes');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los visitantes: ${e.toString()}');
    }
  }
  
  // Obtener visitante por ID
  Future<Visitor> getVisitorById(int id) async {
    try {
      final response = await _visitorService.getVisitorById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al obtener el visitante');
      }
    } catch (e) {
      throw Exception('No se pudo cargar el visitante: ${e.toString()}');
    }
  }
  
  // Crear visitante
  Future<Visitor> createVisitor({
    required String name,
    String? documentId,
    String? purpose,
    DateTime? entryTime,
    int? propertyId,
  }) async {
    try {
      final visitorData = {
        'name': name,
        if (documentId != null) 'document_id': documentId,
        if (purpose != null) 'purpose': purpose,
        if (entryTime != null) 'entry_time': entryTime.toIso8601String(),
        if (propertyId != null) 'property_id': propertyId,
      };
      
      final response = await _visitorService.createVisitor(visitorData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al crear el visitante');
      }
    } catch (e) {
      throw Exception('No se pudo crear el visitante: ${e.toString()}');
    }
  }
  
  // Actualizar visitante
  Future<Visitor> updateVisitor(int id, {
    String? name,
    String? documentId,
    String? purpose,
    DateTime? entryTime,
    DateTime? exitTime,
    int? propertyId,
    String? status,
  }) async {
    try {
      final visitorData = {
        if (name != null) 'name': name,
        if (documentId != null) 'document_id': documentId,
        if (purpose != null) 'purpose': purpose,
        if (entryTime != null) 'entry_time': entryTime.toIso8601String(),
        if (exitTime != null) 'exit_time': exitTime.toIso8601String(),
        if (propertyId != null) 'property_id': propertyId,
        if (status != null) 'status_id': status,
      };
      
      final response = await _visitorService.updateVisitor(id, visitorData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Error al actualizar el visitante');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el visitante: ${e.toString()}');
    }
  }
  
  // Registrar salida de visitante
  Future<Visitor> registerVisitorExit(int id, DateTime exitTime) async {
    try {
      return await updateVisitor(id, exitTime: exitTime);
    } catch (e) {
      throw Exception('No se pudo registrar la salida del visitante: ${e.toString()}');
    }
  }
  
  // Eliminar visitante
  Future<bool> deleteVisitor(int id) async {
    try {
      final response = await _visitorService.deleteVisitor(id);
      
      if (response.success && response.data != null) {
        return true;
      } else {
        throw Exception(response.message ?? 'Error al eliminar el visitante');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar el visitante: ${e.toString()}');
    }
  }
}