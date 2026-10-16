import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';

/// Pantalla de bienvenida mostrada únicamente en la primera ejecución de la app.
/// Solicita al usuario su nombre y su objetivo diario de hábitos.
class BienvenidaScreen extends StatefulWidget {
  final VoidCallback onBienvenidaCompletada;

  const BienvenidaScreen({
    super.key,
    required this.onBienvenidaCompletada,
  });

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _objetivoController = TextEditingController(text: '3');
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _guardarYContinuar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _guardando = true;
      });

      final nombre = _nombreController.text.trim();
      final objetivo = int.parse(_objetivoController.text.trim());

      // Guardamos el nombre (TIPO String) y el objetivo (TIPO int) en SharedPreferences a través del servicio
      await PreferenciasService.guardarBienvenida(nombre, objetivo);

      // Si no hay hábitos creados, creamos unos hábitos por defecto para comenzar
      final habitosExistentes = await PreferenciasService.getHabitos();
      if (habitosExistentes.isEmpty) {
        final habitosIniciales = [
          Habito(
            id: '1',
            nombre: 'Beber 2 Litros de agua',
            colorValue: Colors.blue.toARGB32(),
          ),
          Habito(
            id: '2',
            nombre: 'Caminar 30 minutos',
            colorValue: Colors.green.toARGB32(),
          ),
          Habito(
            id: '3',
            nombre: 'Leer 15 minutos',
            colorValue: Colors.orange.toARGB32(),
          ),
        ];
        await PreferenciasService.guardarHabitos(habitosIniciales);
      }

      if (mounted) {
        setState(() {
          _guardando = false;
        });
        widget.onBienvenidaCompletada();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono de bienvenida
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 90,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¡Bienvenido a HábitosApp!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Registra y mejora tus hábitos diarios de forma sencilla.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 36),

                  // Campo: Nombre de usuario
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: '¿Cómo te llamas?',
                      hintText: 'Tu nombre o apodo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, introduce tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo: Objetivo diario
                  TextFormField(
                    controller: _objetivoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Objetivo diario de hábitos',
                      hintText: 'Número de hábitos que quieres lograr al día',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Introduce un número de hábitos objetivo';
                      }
                      final num = int.tryParse(value.trim());
                      if (num == null || num <= 0) {
                        return 'Debe ser un número mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón para comenzar
                  ElevatedButton(
                    onPressed: _guardando ? null : _guardarYContinuar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Comenzar',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
