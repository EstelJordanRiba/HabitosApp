import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Modelo de datos para gestionar un hábito en la app
class Habito {
  final String id;
  final String nombre;
  final String colorNombre; // 'Azul', 'Verde', 'Naranja', 'Rojo', 'Morado', 'Rosa', 'Amarillo', 'Cian'
  final int colorValue;
  final List<String> fechasCompletadas; // Fechas en formato 'yyyy-MM-dd'

  Habito({
    required this.id,
    required this.nombre,
    this.colorNombre = 'Azul',
    int? colorValue,
    List<String>? fechasCompletadas,
  })  : colorValue = colorValue ?? _obtenerColorValue(colorNombre),
        fechasCompletadas = fechasCompletadas ?? [];

  // Mapea el nombre del color a su valor ARGB en Flutter
  static int _obtenerColorValue(String nombreColor) {
    switch (nombreColor.toLowerCase()) {
      case 'verde':
        return Colors.green.toARGB32();
      case 'naranja':
        return Colors.orange.toARGB32();
      case 'rojo':
        return Colors.red.toARGB32();
      case 'morado':
        return Colors.purple.toARGB32();
      case 'rosa':
        return Colors.pink.toARGB32();
      case 'amarillo':
        return Colors.amber.toARGB32();
      case 'cian':
      case 'turquesa':
        return Colors.teal.toARGB32();
      case 'azul':
      default:
        return Colors.blue.toARGB32();
    }
  }

  // Obtiene la fecha actual en formato yyyy-MM-dd usando intl
  static String get fechaHoyStr {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Comprueba si el hábito ya se ha hecho hoy
  bool get isCompletadoHoy {
    return fechasCompletadas.contains(fechaHoyStr);
  }

  // Cuenta el total de días completados
  int get totalDiasCompletados => fechasCompletadas.length;

  // Marca o desmarca el hábito para el día de hoy
  Habito toggleCompletadoHoy() {
    final hoy = fechaHoyStr;
    final nuevaLista = List<String>.from(fechasCompletadas);

    if (nuevaLista.contains(hoy)) {
      nuevaLista.remove(hoy);
    } else {
      nuevaLista.add(hoy);
    }

    return copyWith(fechasCompletadas: nuevaLista);
  }

  // Calcula la racha de días seguidos completados
  int calcularRachaActual() {
    if (fechasCompletadas.isEmpty) return 0;

    final fechasOrdenadas = fechasCompletadas.toSet().toList()..sort();
    final hoy = DateTime.now();
    final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);

    int racha = 0;
    DateTime fechaEvaluar = hoySoloFecha;

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

  // Convierte el objeto a Map para guardar en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'colorNombre': colorNombre,
      'colorValue': colorValue,
      'fechasCompletadas': fechasCompletadas,
    };
  }

  // Crea un Habito a partir de los datos decodificados de JSON
  factory Habito.fromJson(Map<String, dynamic> json) {
    final colorNom = json['colorNombre'] as String? ?? 'Azul';
    return Habito(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      colorNombre: colorNom,
      colorValue: json['colorValue'] as int? ?? _obtenerColorValue(colorNom),
      fechasCompletadas: (json['fechasCompletadas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  // Permite clonar el objeto modificando campos concretos
  Habito copyWith({
    String? id,
    String? nombre,
    String? colorNombre,
    int? colorValue,
    List<String>? fechasCompletadas,
  }) {
    final nuevoColorNom = colorNombre ?? this.colorNombre;
    return Habito(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      colorNombre: nuevoColorNom,
      colorValue: colorValue ?? _obtenerColorValue(nuevoColorNom),
      fechasCompletadas: fechasCompletadas ?? this.fechasCompletadas,
    );
  }
}
