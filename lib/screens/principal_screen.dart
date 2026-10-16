import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/habito_card.dart';
import '../widgets/habito_dialog.dart';

/// Pantalla Principal de la aplicación.
/// Muestra el saludo al usuario, el progreso diario y la lista de hábitos.
class PrincipalScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const PrincipalScreen({super.key, required this.onDataChanged});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool _cargando = true;
  String _nombreUsuario = '';
  int _objetivoDiario = 3;
  bool _ocultarCompletados = false;
  double _tamanoLetra = 16.0;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Carga asíncrona de datos desde SharedPreferences usando el servicio.
  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    final nombre = await PreferenciasService.getNombreUsuario() ?? 'Usuario';
    final objetivo = await PreferenciasService.getObjetivoDiario();
    final ocultar = await PreferenciasService.getOcultarCompletados();
    final tamano = await PreferenciasService.getTamanoLetra();
    final listaHabitos = await PreferenciasService.getHabitos();

    if (mounted) {
      setState(() {
        _nombreUsuario = nombre;
        _objetivoDiario = objetivo;
        _ocultarCompletados = ocultar;
        _tamanoLetra = tamano;
        _habitos = listaHabitos;
        _cargando = false;
      });
    }
  }

  /// Alterna el estado completado de hoy para un hábito específico.
  Future<void> _toggleHabito(Habito habito) async {
    final habitoActualizado = habito.toggleCompletadoHoy();
    final index = _habitos.indexWhere((h) => h.id == habito.id);
    if (index != -1) {
      setState(() {
        _habitos[index] = habitoActualizado;
      });
      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged();
    }
  }

  /// Abre el diálogo para crear un nuevo hábito.
  Future<void> _crearHabito() async {
    final nuevoHabito = await showDialog<Habito>(
      context: context,
      builder: (context) => const HabitoDialog(),
    );

    if (nuevoHabito != null) {
      setState(() {
        _habitos.add(nuevoHabito);
      });
      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged();
    }
  }

  /// Abre el diálogo para editar un hábito existente.
  Future<void> _editarHabito(Habito habito) async {
    final habitoEditado = await showDialog<Habito>(
      context: context,
      builder: (context) => HabitoDialog(habito: habito),
    );

    if (habitoEditado != null) {
      final index = _habitos.indexWhere((h) => h.id == habito.id);
      if (index != -1) {
        setState(() {
          _habitos[index] = habitoEditado;
        });
        await PreferenciasService.guardarHabitos(_habitos);
        widget.onDataChanged();
      }
    }
  }

  /// Muestra un diálogo de confirmación y borra el hábito seleccionado.
  Future<void> _borrarHabito(Habito habito) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Estás seguro de que quieres borrar el hábito "${habito.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() {
        _habitos.removeWhere((h) => h.id == habito.id);
      });
      await PreferenciasService.guardarHabitos(_habitos);
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final habitosCompletadosHoy = _habitos.where((h) => h.isCompletadoHoy).length;
    final totalHabitos = _habitos.length;
    final progreso = totalHabitos > 0 ? (habitosCompletadosHoy / totalHabitos) : 0.0;

    // Filtramos si la opción de ocultar completados está activa
    final habitosVisibles = _ocultarCompletados
        ? _habitos.where((h) => !h.isCompletadoHoy).toList()
        : _habitos;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner superior con saludo y progreso
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $_nombreUsuario! 👋',
                    style: TextStyle(
                      fontSize: _tamanoLetra * 1.3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progreso de hoy: $habitosCompletadosHoy de $totalHabitos hábitos (Objetivo diario: $_objetivoDiario)',
                    style: TextStyle(
                      fontSize: _tamanoLetra * 0.9,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progreso.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                    ),
                  ),
                  if (habitosCompletadosHoy >= _objetivoDiario && _objetivoDiario > 0) ...[
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amberAccent, size: 20),
                        SizedBox(width: 6),
                        Text(
                          '¡Has alcanzado tu objetivo diario! 🎉',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Título de la lista
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Hábitos',
                    style: TextStyle(
                      fontSize: _tamanoLetra * 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_ocultarCompletados)
                    Chip(
                      avatar: const Icon(Icons.visibility_off, size: 16),
                      label: const Text('Completados ocultos'),
                      backgroundColor: Colors.orange.shade100,
                    ),
                ],
              ),
            ),
          ),

          // Lista de hábitos
          if (habitosVisibles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      _ocultarCompletados && habitosCompletadosHoy > 0
                          ? '¡Todos los hábitos de hoy están completados!'
                          : 'No hay hábitos creados aún.',
                      style: TextStyle(
                        fontSize: _tamanoLetra,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toca el botón + para añadir un nuevo hábito.',
                      style: TextStyle(
                        fontSize: _tamanoLetra * 0.85,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habito = habitosVisibles[index];
                  return HabitoCard(
                    habito: habito,
                    tamanoLetra: _tamanoLetra,
                    onToggleCompletado: (_) => _toggleHabito(habito),
                    onEdit: () => _editarHabito(habito),
                    onDelete: () => _borrarHabito(habito),
                  );
                },
                childCount: habitosVisibles.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearHabito,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Hábito'),
      ),
    );
  }
}
