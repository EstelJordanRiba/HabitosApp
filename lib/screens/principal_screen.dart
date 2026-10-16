import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import 'editar_habito_screen.dart';

// Pantalla principal con el saludo, objetivo diario y la lista de fichas de hábitos
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

  // Plantillas de hábitos con variedad de colores
  final List<Map<String, String>> _plantillasHabitos = [
    {'nombre': 'Beber agua', 'color': 'Azul'},
    {'nombre': 'Caminar 30 min', 'color': 'Verde'},
    {'nombre': 'Leer 15 min', 'color': 'Naranja'},
    {'nombre': 'Hacer ejercicio', 'color': 'Rojo'},
    {'nombre': 'Pasear al perro', 'color': 'Amarillo'},
    {'nombre': 'Meditar 10 min', 'color': 'Morado'},
    {'nombre': 'Comer fruta', 'color': 'Rosa'},
    {'nombre': 'Dormir 8 horas', 'color': 'Cian'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Carga el usuario, objetivo diario y los hábitos guardados
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

    // Si no hay hábitos creados, generamos hábitos de ejemplo según el objetivo
    if (lista.isEmpty) {
      final cantidad = objetivo.clamp(1, _plantillasHabitos.length);
      lista = List.generate(cantidad, (i) {
        final p = _plantillasHabitos[i];
        return Habito(
          id: (i + 1).toString(),
          nombre: p['nombre']!,
          colorNombre: p['color']!,
        );
      });
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

  // Abre la pantalla de edición, espera el resultado con await y actualiza con setState
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

  // Diálogo para crear un nuevo hábito eligiendo nombre y color
  Future<void> _crearNuevoHabito() async {
    final controller = TextEditingController();
    String colorSeleccionado = 'Azul';
    final coloresDisponibles = ['Azul', 'Verde', 'Naranja', 'Rojo', 'Morado', 'Rosa', 'Amarillo', 'Cian'];

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Nuevo Hábito'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del hábito',
                        hintText: 'Ej. Correr, Leer...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Selecciona un color:'),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: coloresDisponibles.map((c) {
                        final sel = colorSeleccionado == c;
                        return ChoiceChip(
                          label: Text(c),
                          selected: sel,
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                colorSeleccionado = c;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final txt = controller.text.trim();
                    if (txt.isNotEmpty) {
                      Navigator.pop(context, {'nombre': txt, 'color': colorSeleccionado});
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (result != null) {
      final nuevo = Habito(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: result['nombre']!,
        colorNombre: result['color']!,
      );

      setState(() {
        _habitos.add(nuevo);
      });

      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged?.call();
    }
  }

  // Eliminar hábito
  Future<void> _borrarHabito(Habito habito) async {
    final borrado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar hábito'),
        content: Text('¿Seguro que quieres borrar "${habito.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (borrado == true) {
      setState(() {
        _habitos.removeWhere((h) => h.id == habito.id);
      });
      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged?.call();
    }
  }

  // Marca o desmarca el hábito
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
      case 'rojo':
        return Colors.red;
      case 'morado':
        return Colors.purple;
      case 'rosa':
        return Colors.pink;
      case 'amarillo':
        return Colors.amber;
      case 'cian':
        return Colors.teal;
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tus Hábitos:',
                  style: TextStyle(
                    fontSize: _tamanoLetra * 1.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _crearNuevoHabito,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir hábito'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fichas de los hábitos
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
                            // Nombre del hábito
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
                            // Etiqueta del color por su nombre
                            Chip(
                              avatar: CircleAvatar(backgroundColor: colorWidget),
                              label: Text(
                                habito.colorNombre,
                                style: TextStyle(fontSize: _tamanoLetra * 0.8),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _borrarHabito(habito),
                              tooltip: 'Borrar hábito',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _crearNuevoHabito,
        tooltip: 'Nuevo hábito',
        child: const Icon(Icons.add),
      ),
    );
  }
}
