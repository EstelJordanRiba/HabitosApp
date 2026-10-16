import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';

/// Pantalla de Ajustes de la aplicación.
/// Permite configurar el tema, el tamaño de la letra, ocultar hábitos completados y restablecer los datos.
class AjustesScreen extends StatefulWidget {
  final VoidCallback onAppSettingsChanged;
  final VoidCallback onResetApp;

  const AjustesScreen({
    super.key,
    required this.onAppSettingsChanged,
    required this.onResetApp,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _cargando = true;
  bool _isDarkMode = false;
  double _tamanoLetra = 16.0;
  bool _ocultarCompletados = false;
  String _nombreUsuario = '';
  int _objetivoDiario = 3;

  @override
  void initState() {
    super.initState();
    _cargarAjustes();
  }

  /// Carga de los ajustes guardados en SharedPreferences
  Future<void> _cargarAjustes() async {
    setState(() {
      _cargando = true;
    });

    final isDark = await PreferenciasService.getIsDarkMode();
    final tamano = await PreferenciasService.getTamanoLetra();
    final ocultar = await PreferenciasService.getOcultarCompletados();
    final nombre = await PreferenciasService.getNombreUsuario() ?? '';
    final objetivo = await PreferenciasService.getObjetivoDiario();

    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
        _tamanoLetra = tamano;
        _ocultarCompletados = ocultar;
        _nombreUsuario = nombre;
        _objetivoDiario = objetivo;
        _cargando = false;
      });
    }
  }

  /// Diálogo para editar el perfil (Nombre y Objetivo)
  Future<void> _editarPerfil() async {
    final nombreController = TextEditingController(text: _nombreUsuario);
    final objetivoController = TextEditingController(text: _objetivoDiario.toString());
    final formKey = GlobalKey<FormState>();

    final guardado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Introduce un nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: objetivoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objetivo diario',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (v) {
                  final num = int.tryParse(v ?? '');
                  if (num == null || num <= 0) {
                    return 'Introduce un número mayor a 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardado == true) {
      final nuevoNombre = nombreController.text.trim();
      final nuevoObjetivo = int.parse(objetivoController.text.trim());

      await PreferenciasService.setNombreUsuario(nuevoNombre);
      await PreferenciasService.setObjetivoDiario(nuevoObjetivo);

      setState(() {
        _nombreUsuario = nuevoNombre;
        _objetivoDiario = nuevoObjetivo;
      });
      widget.onAppSettingsChanged();
    }
  }

  /// Diálogo de confirmación para borrar todos los datos
  Future<void> _confirmarBorradoDatos() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('¿Borrar todos los datos?'),
          ],
        ),
        content: const Text(
          'Esta acción eliminará permanentemente todos tus hábitos, estadísticas y configuraciones. La aplicación volverá a mostrar la pantalla de bienvenida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Borrar todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      // Borra todas las preferencias locales usando PreferenciasService
      await PreferenciasService.borrarTodo();
      if (mounted) {
        widget.onResetApp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de Perfil
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                _nombreUsuario,
                style: TextStyle(
                  fontSize: _tamanoLetra * 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Objetivo diario: $_objetivoDiario hábitos',
                style: TextStyle(fontSize: _tamanoLetra * 0.85),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editarPerfil,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sección de Preferencias de Interfaz
          Text(
            'Personalización y Preferencias',
            style: TextStyle(
              fontSize: _tamanoLetra * 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                // Tema claro / oscuro (TIPO bool)
                SwitchListTile(
                  secondary: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: _isDarkMode ? Colors.amber : Colors.orange,
                  ),
                  title: Text(
                    'Tema Oscuro',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  subtitle: Text(
                    _isDarkMode ? 'Modo oscuro activo' : 'Modo claro activo',
                    style: TextStyle(fontSize: _tamanoLetra * 0.8),
                  ),
                  value: _isDarkMode,
                  onChanged: (val) async {
                    setState(() {
                      _isDarkMode = val;
                    });
                    // TIPO 3: bool en SharedPreferences
                    await PreferenciasService.setIsDarkMode(val);
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Interruptor para ocultar completados (TIPO bool)
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_off, color: Colors.blue),
                  title: Text(
                    'Ocultar hábitos completados hoy',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  subtitle: Text(
                    'Oculta de la lista principal los hábitos marcados como hechos',
                    style: TextStyle(fontSize: _tamanoLetra * 0.8),
                  ),
                  value: _ocultarCompletados,
                  onChanged: (val) async {
                    setState(() {
                      _ocultarCompletados = val;
                    });
                    // TIPO 3: bool en SharedPreferences
                    await PreferenciasService.setOcultarCompletados(val);
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Control deslizante para el tamaño de letra (TIPO double)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_fields, color: Colors.teal),
                              const SizedBox(width: 12),
                              Text(
                                'Tamaño de letra',
                                style: TextStyle(fontSize: _tamanoLetra),
                              ),
                            ],
                          ),
                          Text(
                            '${_tamanoLetra.toInt()} px',
                            style: TextStyle(
                              fontSize: _tamanoLetra * 0.9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Control deslizante (Slider)
                      Slider(
                        value: _tamanoLetra,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        label: '${_tamanoLetra.toInt()} px',
                        onChanged: (val) {
                          setState(() {
                            _tamanoLetra = val;
                          });
                        },
                        onChangeEnd: (val) async {
                          // TIPO 4: double en SharedPreferences
                          await PreferenciasService.setTamanoLetra(val);
                          widget.onAppSettingsChanged();
                        },
                      ),
                      Text(
                        'Vista previa del tamaño de texto actual.',
                        style: TextStyle(fontSize: _tamanoLetra, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección de Borrado de Datos
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red, size: 32),
              title: const Text(
                'Borrar todos los datos',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Restablece la app como si estuviera recién instalada',
                style: TextStyle(color: Colors.redAccent),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _confirmarBorradoDatos,
                child: const Text('Borrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
