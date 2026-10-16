import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import 'editar_habito_screen.dart';

// Pantalla principal donde se saluda al usuario, se muestra el objetivo y la ficha del hábito
class PrincipalScreen extends StatefulWidget {
  final String? nombreUsuarioInicial;
  final int? objetivoDiarioInicial;
  final VoidCallback? onDataChanged;

  const PrincipalScreen({
    super.key,
    this.nombreUsuarioInicial,
    this.objetivoDiarioInicial,
    this.onDataChanged,
  });

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool _cargando = true;
  String _nombreUsuario = 'Usuario';
  int _objetivoDiario = 3;
  double _tamanoLetra = 16.0;
  bool _ocultarCompletados = false;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Carga el nombre del usuario, objetivo diario y hábitos desde SharedPreferences
  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    final nombre = widget.nombreUsuarioInicial ??
        await PreferenciasService.getNombreUsuario() ??
        'Usuario';
    final objetivo = widget.objetivoDiarioInicial ??
        await PreferenciasService.getObjetivoDiario();
    final tamano = await PreferenciasService.getTamanoLetra();
    final ocultar = await PreferenciasService.getOcultarCompletados();
    var lista = await PreferenciasService.getHabitos();

    // Si aún no hay hábitos creados, inicializamos con el hábito de ejemplo "Beber agua"
    if (lista.isEmpty) {
      lista = [
        Habito(
          id: '1',
          nombre: 'Beber agua',
          colorNombre: 'Azul',
        ),
      ];
      await PreferenciasService.guardarHabitos(lista);
    }

    if (!mounted) return;

    setState(() {
      _nombreUsuario = nombre;
      _objetivoDiario = objetivo;
      _tamanoLetra = tamano;
      _ocultarCompletados = ocultar;
      _habitos = lista;
      _cargando = false;
    });
  }

  // Abre la pantalla de edición, espera el resultado con await y actualiza con setState si hay cambios
  Future<void> _editarHabito(Habito habito) async {
    final resultado = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHabitoScreen(
          nombreInicial: habito.nombre,
          colorInicial: habito.colorNombre,
        ),
      ),
    );

    if (!mounted) return;

    // Si hemos recibido datos de vuelta al pulsar Guardar, actualizamos la lista
    if (resultado != null) {
      final nuevoNombre = resultado['nombre'] ?? habito.nombre;
      final nuevoColorNombre = resultado['color'] ?? habito.colorNombre;

      setState(() {
        final index = _habitos.indexWhere((h) => h.id == habito.id);
        if (index != -1) {
          _habitos[index] = _habitos[index].copyWith(
            nombre: nuevoNombre,
            colorNombre: nuevoColorNombre,
          );
        }
      });

      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged?.call();
    }
  }

  // Marca o desmarca el hábito como hecho hoy
  Future<void> _toggleCompletado(Habito habito) async {
    final habitoActualizado = habito.toggleCompletadoHoy();
    final index = _habitos.indexWhere((h) => h.id == habito.id);

    if (index != -1) {
      setState(() {
        _habitos[index] = habitoActualizado;
      });
      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged?.call();
    }
  }

  Color _obtenerColorWidget(String nombreColor) {
    switch (nombreColor.toLowerCase()) {
      case 'verde':
        return Colors.green;
      case 'naranja':
        return Colors.orange;
      case 'azul':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final completadosHoy = _habitos.where((h) => h.isCompletadoHoy).length;
    final habitosAMostrar = _ocultarCompletados
        ? _habitos.where((h) => !h.isCompletadoHoy).toList()
        : _habitos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HábitosApp - Principal'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saludo y objetivo diario
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $_nombreUsuario!',
                      style: TextStyle(
                        fontSize: _tamanoLetra * 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tu objetivo diario es: $_objetivoDiario hábitos',
                            style: TextStyle(
                              fontSize: _tamanoLetra,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progreso de hoy: $completadosHoy de ${_habitos.length} completados',
                      style: TextStyle(
                        fontSize: _tamanoLetra * 0.85,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Tus Hábitos:',
              style: TextStyle(
                fontSize: _tamanoLetra * 1.15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Ficha de cada hábito
            if (habitosAMostrar.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    _ocultarCompletados
                        ? 'Todos los hábitos están completados hoy.'
                        : 'No tienes hábitos guardados.',
                    style: TextStyle(fontSize: _tamanoLetra, color: Colors.grey),
                  ),
                ),
              )
            else
              ...habitosAMostrar.map((habito) {
                final isCompletado = habito.isCompletadoHoy;
                final colorWidget = _obtenerColorWidget(habito.colorNombre);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorWidget, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorWidget.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.water_drop,
                                color: colorWidget,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nombre del hábito destacado
                            Expanded(
                              child: Text(
                                habito.nombre,
                                style: TextStyle(
                                  fontSize: _tamanoLetra * 1.1,
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompletado
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            // Nombre del color
                            Chip(
                              avatar: CircleAvatar(backgroundColor: colorWidget),
                              label: Text(
                                habito.colorNombre,
                                style: TextStyle(fontSize: _tamanoLetra * 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Estado del hábito y botón Editar hábito
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCompletado
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isCompletado ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCompletado ? 'Completado' : 'Pendiente',
                                  style: TextStyle(
                                    fontSize: _tamanoLetra * 0.9,
                                    fontWeight: FontWeight.w600,
                                    color: isCompletado
                                        ? Colors.green
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _toggleCompletado(habito),
                                  child: Text(
                                    isCompletado ? 'Desmarcar' : 'Completar',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _editarHabito(habito),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Editar hábito'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
