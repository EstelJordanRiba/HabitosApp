import 'package:flutter/material.dart';
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
  // Controladores para los dos campos de texto
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
    // Liberamos los controladores al salir de la pantalla
    _nombreController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  // Valida los datos introducidos, los guarda en SharedPreferences y navega a la pantalla principal
  Future<void> _comenzar() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text.trim();
      final objetivo = int.parse(_objetivoController.text.trim());

      await PreferenciasService.guardarBienvenida(nombre, objetivo);

      if (!mounted) return;

      if (widget.onBienvenidaCompletada != null) {
        widget.onBienvenidaCompletada!();
      } else {
        // Pasamos los datos al constructor de PrincipalScreen
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
      // SingleChildScrollView para evitar desbordamientos cuando sale el teclado
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

              // Campo para el nombre del usuario
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

              // Campo para el objetivo diario de hábitos
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

              // Botón para acceder a la pantalla principal
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
