import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';

/// PANTALLA: AjustesScreen
/// Permite configurar el Tema Claro/Oscuro (bool), Tamaño de letra (double con Slider),
/// Ocultar completados (bool) y el botón para Borrar todos los datos.
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

  /// Carga asíncrona de ajustes desde SharedPreferences
  Future<void> _cargarAjustes() async {
    setState(() {
      _cargando = true;
    });

    final isDark = await PreferenciasService.getIsDarkMode();
    final tamano = await PreferenciasService.getTamanoLetra();
    final ocultar = await PreferenciasService.getOcultarCompletados();
    final nombre = await PreferenciasService.getNombreUsuario() ?? '';
    final objetivo = await PreferenciasService.getObjetivoDiario();

    if (!mounted) return;

    setState(() {
      _isDarkMode = isDark;
      _tamanoLetra = tamano;
      _ocultarCompletados = ocultar;
      _nombreUsuario = nombre;
      _objetivoDiario = objetivo;
      _cargando = false;
    });
  }

  /// Confirma y ejecuta el borrado total de datos
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
      // Borra todo SharedPreferences y llama a reset
      await PreferenciasService.borrarTodo();
      if (mounted) {
        widget.onResetApp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HábitosApp - Ajustes'),
        elevation: 2,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Perfil actual
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
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
            ),
          ),
          const SizedBox(height: 16),

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
                // Tema Oscuro (bool)
                SwitchListTile(
                  secondary: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: _isDarkMode ? Colors.amber : Colors.orange,
                  ),
                  title: Text(
                    'Tema Oscuro',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  value: _isDarkMode,
                  onChanged: (val) async {
                    setState(() {
                      _isDarkMode = val;
                    });
                    await PreferenciasService.setIsDarkMode(val);
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Ocultar completados (bool)
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_off, color: Colors.blue),
                  title: Text(
                    'Ocultar hábitos completados hoy',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  value: _ocultarCompletados,
                  onChanged: (val) async {
                    setState(() {
                      _ocultarCompletados = val;
                    });
                    await PreferenciasService.setOcultarCompletados(val);
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Tamaño de letra con Slider (double)
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
                      // CONTROL DESLIZANTE SLIDER (double)
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
                          await PreferenciasService.setTamanoLetra(val);
                          widget.onAppSettingsChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // BORRAR TODOS LOS DATOS
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
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Restablece la app como recién instalada',
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
