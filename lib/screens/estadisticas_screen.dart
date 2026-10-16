import 'package:flutter/material.dart';
import '../models/habito.dart';
import '../services/preferencias_service.dart';

/// PANTALLA: EstadisticasScreen
/// Muestra métricas de uso de la app (aperturas, fecha/hora de última apertura)
/// y la racha actual y total de días completados de cada hábito.
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  bool _cargando = true;
  int _contadorAperturas = 0;
  String _ultimaApertura = '';
  double _tamanoLetra = 16.0;
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  /// Carga asíncrona de estadísticas desde SharedPreferences
  Future<void> _cargarEstadisticas() async {
    setState(() {
      _cargando = true;
    });

    final contador = await PreferenciasService.getContadorAperturas();
    final ultima = await PreferenciasService.getUltimaApertura();
    final tamano = await PreferenciasService.getTamanoLetra();
    final lista = await PreferenciasService.getHabitos();

    if (!mounted) return;

    setState(() {
      _contadorAperturas = contador;
      _ultimaApertura = ultima;
      _tamanoLetra = tamano;
      _habitos = lista;
      _cargando = false;
    });
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
        title: const Text('HábitosApp - Estadísticas'),
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Uso',
              style: TextStyle(
                fontSize: _tamanoLetra * 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de Aperturas y Última Apertura
            Row(
              children: [
                Expanded(
                  child: _buildTarjetaMetrica(
                    icon: Icons.touch_app,
                    color: Colors.blue,
                    titulo: 'Aperturas',
                    valor: '$_contadorAperturas veces',
                    subtitulo: 'Total de usos',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTarjetaMetrica(
                    icon: Icons.access_time,
                    color: Colors.purple,
                    titulo: 'Última Apertura',
                    valor: _ultimaApertura,
                    subtitulo: 'Fecha y Hora',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Rachas y Rendimiento por Hábito',
              style: TextStyle(
                fontSize: _tamanoLetra * 1.15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_habitos.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No hay hábitos registrados para calcular estadísticas.',
                      style: TextStyle(
                        fontSize: _tamanoLetra,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _habitos.length,
                itemBuilder: (context, index) {
                  final habito = _habitos[index];
                  final racha = habito.calcularRachaActual();
                  final totalDias = habito.totalDiasCompletados;
                  final colorHabito = Color(habito.colorValue);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: colorHabito,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  habito.nombre,
                                  style: TextStyle(
                                    fontSize: _tamanoLetra,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Racha
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department,
                                          color: Colors.orange, size: 24),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$racha',
                                        style: TextStyle(
                                          fontSize: _tamanoLetra * 1.2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Racha Actual',
                                    style: TextStyle(
                                      fontSize: _tamanoLetra * 0.8,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              // Días completados
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: Colors.green, size: 22),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$totalDias',
                                        style: TextStyle(
                                          fontSize: _tamanoLetra * 1.2,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Días Completados',
                                    style: TextStyle(
                                      fontSize: _tamanoLetra * 0.8,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaMetrica({
    required IconData icon,
    required Color color,
    required String titulo,
    required String valor,
    required String subtitulo,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 18,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: _tamanoLetra * 0.85,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: TextStyle(
                fontSize: _tamanoLetra,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: _tamanoLetra * 0.75,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
