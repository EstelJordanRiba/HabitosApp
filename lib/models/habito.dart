import 'package:intl/intl.dart';

/// Modelo de datos que representa un Hábito en la aplicación.
/// Incluye serialización JSON para poder guardarlo mediante SharedPreferences.
class Habito {
  final String id;
  final String nombre;
  final int colorValue; // Guardamos el valor entero del Color (ARGB)
  final List<String> fechasCompletadas; // Fechas en formato 'yyyy-MM-dd'

  Habito({
    required this.id,
    required this.nombre,
    required this.colorValue,
    List<String>? fechasCompletadas,
  }) : fechasCompletadas = fechasCompletadas ?? [];

  /// Convierte el objeto Habito a un Map para serializarlo en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'colorValue': colorValue,
      'fechasCompletadas': fechasCompletadas,
    };
  }

  /// Construye una instancia de Habito a partir de un Map deserializado de JSON.
  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      colorValue: json['colorValue'] as int,
      fechasCompletadas: (json['fechasCompletadas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Formatea la fecha de hoy a 'yyyy-MM-dd' usando intl.
  /// Comentario intl: La librería 'intl' nos permite formatear objetos DateTime a cadenas estandarizadas.
  static String get _fechaHoyStr {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Obtiene el total de días completados
  int get totalDiasCompletados => fechasCompletadas.length;

  /// Comprueba si el hábito se ha completado hoy.
  bool get isCompletadoHoy {
    return fechasCompletadas.contains(_fechaHoyStr);
  }

  /// Alterna el estado de completado para el día de hoy.
  Habito toggleCompletadoHoy() {
    final hoy = _fechaHoyStr;
    final nuevaLista = List<String>.from(fechasCompletadas);

    if (nuevaLista.contains(hoy)) {
      nuevaLista.remove(hoy);
    } else {
      nuevaLista.add(hoy);
    }

    return copyWith(fechasCompletadas: nuevaLista);
  }

  /// Calcula la racha actual de días consecutivos en los que se ha completado el hábito.
  int calcularRachaActual() {
    if (fechasCompletadas.isEmpty) return 0;

    final fechasOrdenadas = fechasCompletadas.toSet().toList()..sort();
    final hoy = DateTime.now();
    final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);

    int racha = 0;
    DateTime fechaEvaluar = hoySoloFecha;

    // Si hoy no se ha completado, verificamos si ayer sí se completó para mantener la racha activa
    final hoyStr = DateFormat('yyyy-MM-dd').format(hoySoloFecha);
    if (!fechasOrdenadas.contains(hoyStr)) {
      fechaEvaluar = hoySoloFecha.subtract(const Duration(days: 1));
    }

    while (true) {
      final fechaStr = DateFormat('yyyy-MM-dd').format(fechaEvaluar);
      if (fechasOrdenadas.contains(fechaStr)) {
        racha++;
        fechaEvaluar = fechaEvaluar.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return racha;
  }

  /// Crea una copia del objeto actual modificando los campos especificados.
  Habito copyWith({
    String? id,
    String? nombre,
    int? colorValue,
    List<String>? fechasCompletadas,
  }) {
    return Habito(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      colorValue: colorValue ?? this.colorValue,
      fechasCompletadas: fechasCompletadas ?? this.fechasCompletadas,
    );
  }
}
