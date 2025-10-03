import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/parking_slot.dart';
import '../../../services/parking_slot_service.dart';
import '../providers/parking_slot_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiTesterScreen extends StatefulWidget {
  const ApiTesterScreen({super.key});

  @override
  _ApiTesterScreenState createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  final TextEditingController _endpointController = TextEditingController(text: 'http://localhost:3000/api_v1/parkingslot');
  final TextEditingController _resultController = TextEditingController();
  bool _isLoading = false;
  String _error = '';
  String _responseBody = '';
  int _statusCode = 0;
  bool _success = false;

  @override
  void dispose() {
    _endpointController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _testDirectApiConnection() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _responseBody = '';
      _statusCode = 0;
      _success = false;
    });

    try {
      final uri = Uri.parse(_endpointController.text);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      setState(() {
        _isLoading = false;
        _statusCode = response.statusCode;
        _responseBody = response.body;
        
        try {
          final jsonData = json.decode(response.body);
          _success = jsonData['success'] ?? false;
          if (jsonData['data'] != null) {
            _resultController.text = 'Datos recibidos: ${jsonData['data'].length} elementos\n\n${const JsonEncoder.withIndent('  ').convert(jsonData)}';
          } else {
            _resultController.text = const JsonEncoder.withIndent('  ').convert(jsonData);
          }
        } catch (e) {
          _resultController.text = 'Error al analizar JSON: $e\n\nRespuesta original:\n${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _resultController.text = 'Error de conexión: $e';
      });
    }
  }

  Future<void> _testServiceApiConnection() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _responseBody = '';
      _statusCode = 0;
      _success = false;
    });

    try {
      final service = ParkingSlotService();
      final response = await service.getParkingSlots();
      
      setState(() {
        _isLoading = false;
        _success = response.success;
        if (response.success && response.data != null) {
          _resultController.text = 'Éxito! Se recibieron ${response.data!.length} elementos\n\n${response.data!.map((slot) => '- ${slot.code}: ${slot.statusName ?? "Sin estado"}').join('\n')}';
        } else {
          _resultController.text = 'Error: ${response.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _resultController.text = 'Error de servicio: $e';
      });
    }
  }

  Future<void> _testProviderApiConnection() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _responseBody = '';
      _statusCode = 0;
      _success = false;
    });

    try {
      final provider = Provider.of<ParkingSlotProvider>(context, listen: false);
      await provider.loadAllSlots();
      
      setState(() {
        _isLoading = false;
        if (provider.errorMessage.isEmpty) {
          _success = true;
          _resultController.text = 'Éxito! Se cargaron ${provider.allSlots.length} espacios de parqueo\n\n${provider.allSlots.map((slot) => '- ${slot.code}: ${slot.statusName ?? "Sin estado"}').join('\n')}';
        } else {
          _success = false;
          _error = provider.errorMessage;
          _resultController.text = 'Error: ${provider.errorMessage}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _resultController.text = 'Error de provider: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'URL del endpoint',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDirectApiConnection,
                  child: const Text('Probar HTTP directo'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testServiceApiConnection,
                  child: const Text('Probar con Service'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testProviderApiConnection,
                  child: const Text('Probar con Provider'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _success ? Icons.check_circle : Icons.error,
                          color: _success ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _success ? 'Éxito!' : (_error.isNotEmpty ? 'Error: $_error' : 'Sin respuesta'),
                          style: TextStyle(
                            color: _success ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_statusCode > 0)
                      Text('Código de estado: $_statusCode'),
                    const SizedBox(height: 8),
                    const Text('Resultado:'),
                    const SizedBox(height: 4),
                    Expanded(
                      child: TextField(
                        controller: _resultController,
                        maxLines: null,
                        expands: true,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}