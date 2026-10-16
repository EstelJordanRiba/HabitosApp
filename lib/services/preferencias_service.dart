import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habito.dart';

// Servicio centralizado para gestionar las preferencias guardadas en local
class PreferenciasService {
  // Claves para SharedPreferences en constantes
  static const String _keyNombreUsuario = 'pref_nombre_usuario';
  static const String _keyObjetivoDiario = 'pref_objetivo_diario';
  static const String _keyContadorAperturas = 'pref_contador_aperturas';
  static const String _keyUltimaApertura = 'pref_ultima_apertura';
  static const String _keyIsDarkMode = 'pref_is_dark_mode';
  static const String _keyTamanoLetra = 'pref_tamano_letra';
  static const String _keyOcultarCompletados = 'pref_ocultar_completados';
  static const String _keyListaHabitos = 'pref_lista_habitos';

  static SharedPreferences? _prefs;

  // Obtiene la instancia de SharedPreferences
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Manejo de Strings (Nombre y Fecha de Apertura) ---

  static Future<String?> getNombreUsuario() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyNombreUsuario);
  }

  static Future<void> setNombreUsuario(String nombre) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyNombreUsuario, nombre);
  }

  static Future<String> getUltimaApertura() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyUltimaApertura) ?? 'Primera apertura de la app';
  }

  // --- Manejo de Integers (Objetivo diario y Contador) ---

  static Future<int> getObjetivoDiario() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyObjetivoDiario) ?? 3;
  }

  static Future<void> setObjetivoDiario(int objetivo) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_keyObjetivoDiario, objetivo);
  }

  static Future<int> getContadorAperturas() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_keyContadorAperturas) ?? 0;
  }

  // Registra la apertura de la app incrementando el contador y guardando la fecha/hora actual
  static Future<void> registrarApertura() async {
    final prefs = await _getPrefs();

    int contador = prefs.getInt(_keyContadorAperturas) ?? 0;
    contador++;
    await prefs.setInt(_keyContadorAperturas, contador);

    // Formateamos la fecha actual usando la librería intl
    final ahora = DateTime.now();
    final fechaStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(ahora);
    await prefs.setString(_keyUltimaApertura, fechaStr);
  }

  // --- Manejo de Booleans (Tema oscuro y Ocultar completados) ---

  static Future<bool> getIsDarkMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  static Future<void> setIsDarkMode(bool isDark) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  static Future<bool> getOcultarCompletados() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyOcultarCompletados) ?? false;
  }

  static Future<void> setOcultarCompletados(bool ocultar) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyOcultarCompletados, ocultar);
  }

  // --- Manejo de Doubles (Tamaño de letra) ---

  static Future<double> getTamanoLetra() async {
    final prefs = await _getPrefs();
    return prefs.getDouble(_keyTamanoLetra) ?? 16.0;
  }

  static Future<void> setTamanoLetra(double tamano) async {
    final prefs = await _getPrefs();
    await prefs.setDouble(_keyTamanoLetra, tamano);
  }

  // --- Manejo de List<String> (Lista de Hábitos serializada en JSON) ---

  // Obtiene la lista de hábitos convirtiendo cada cadena JSON en un objeto Habito
  static Future<List<Habito>> getHabitos() async {
    final prefs = await _getPrefs();
    final List<String>? jsonList = prefs.getStringList(_keyListaHabitos);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    return jsonList.map((strJson) {
      final Map<String, dynamic> map = jsonDecode(strJson);
      return Habito.fromJson(map);
    }).toList();
  }

  // Guarda la lista de hábitos convirtiendo cada objeto a JSON con jsonEncode
  static Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await _getPrefs();

    final List<String> jsonList = habitos.map((habito) {
      return jsonEncode(habito.toJson());
    }).toList();

    await prefs.setStringList(_keyListaHabitos, jsonList);
  }

  // --- Utilidades ---

  // Comprueba si es la primera vez que se abre la app
  static Future<bool> esPrimeraVez() async {
    final nombre = await getNombreUsuario();
    return nombre == null || nombre.trim().isEmpty;
  }

  // Guarda el nombre y el objetivo diario de la pantalla de bienvenida
  static Future<void> guardarBienvenida(String nombre, int objetivo) async {
    await setNombreUsuario(nombre);
    await setObjetivoDiario(objetivo);
  }

  // Borra todos los datos almacenados
  static Future<void> borrarTodo() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
