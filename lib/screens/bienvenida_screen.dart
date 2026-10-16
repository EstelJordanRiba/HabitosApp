import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import 'principal_screen.dart';

// Pantalla de bienvenida que se muestra la primera vez que se ejecuta la app
class BienvenidaScreen extends StatefulWidget {
  final VoidCallback? onBienvenidaCompletada;

  const BienvenidaScreen({
    super.key,
    this.onBienvenidaCompletada,
  });

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _objetivoController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _objetivoController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  // Genera hábitos de ejemplo con variedad de colores según el objetivo
  List<Habito> _generarHabitosIniciales(int objetivo) {
    final plantillas = [
      {'nombre': 'Beber agua', 'color': 'Azul'},
      {'nombre': 'Caminar 30 min', 'color': 'Verde'},
      {'nombre': 'Leer 15 min', 'color': 'Naranja'},
      {'nombre': 'Hacer ejercicio', 'color': 'Rojo'},
      {'nombre': 'Pasear al perro', 'color': 'Amarillo'},
      {'nombre': 'Meditar 10 min', 'color': 'Morado'},
      {'nombre': 'Comer fruta', 'color': 'Rosa'},
      {'nombre': 'Dormir 8 horas', 'color': 'Cian'},
    ];

    final cantidad = objetivo.clamp(1, plantillas.length);
    return List.generate(cantidad, (i) {
      final item = plantillas[i];
      return Habito(
        id: (i + 1).toString(),
        nombre: item['nombre']!,
        colorNombre: item['color']!,
      );
    });
  }

  // Valida los datos introducidos, los guarda en local y navega a la pantalla principal
  Future<void> _comenzar() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text.trim();
      final objetivo = int.parse(_objetivoController.text.trim());

      await PreferenciasService.guardarBienvenida(nombre, objetivo);

      final habitosIniciales = _generarHabitosIniciales(objetivo);
      await PreferenciasService.guardarHabitos(habitosIniciales);

      if (!mounted) return;

      if (widget.onBienvenidaCompletada != null) {
        widget.onBienvenidaCompletada!();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrincipalScreen(
              nombreUsuarioInicial: nombre,
              objetivoDiarioInicial: objetivo,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HábitosApp - Bienvenida'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.task_alt,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bienvenido a HábitosApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configura tus datos iniciales para comenzar a registrar tus hábitos diarios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Campo Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del usuario',
                  hintText: 'Ej. Juan, María...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Objetivo Diario
              TextFormField(
                controller: _objetivoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objetivo diario de hábitos',
                  hintText: 'Número de hábitos objetivo al día',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce un número';
                  }
                  final num = int.tryParse(value.trim());
                  if (num == null || num <= 0) {
                    return 'Debe ser un número entero mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Botón Comenzar
              ElevatedButton.icon(
                onPressed: _comenzar,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Comenzar', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
