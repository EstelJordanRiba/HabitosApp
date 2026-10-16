import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habito.dart';

/// Clase de servicio que encapsula y centraliza todo el acceso a SharedPreferences.
/// Las pantallas de la aplicación nunca interactúan directamente con SharedPreferences.
class PreferenciasService {
  // Constantes para las claves de SharedPreferences. Evita errores por cadenas sueltas.
  static const String _keyNombreUsuario = 'pref_nombre_usuario';
  static const String _keyObjetivoDiario = 'pref_objetivo_diario';
  static const String _keyContadorAperturas = 'pref_contador_aperturas';
  static const String _keyUltimaApertura = 'pref_ultima_apertura';
  static const String _keyIsDarkMode = 'pref_is_dark_mode';
  static const String _keyTamanoLetra = 'pref_tamano_letra';
  static const String _keyOcultarCompletados = 'pref_ocultar_completados';
  static const String _keyListaHabitos = 'pref_lista_habitos';

  // Singleton o métodos estáticos para acceso limpio.
  static SharedPreferences? _prefs;

  /// Obtiene la instancia de SharedPreferences garantizando la asincronía correcta.
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ===========================================================================
  // 1. TIPO STRING: Nombre del Usuario y Fecha/Hora de Última Apertura
  // ===========================================================================

  /// Obtiene el nombre del usuario guardado como String.
  /// Maneja el caso null retornando un valor predeterminado si es la primera vez.
  static Future<String?> getNombreUsuario() async {
    final prefs = await _getPrefs();
    // TIPO 1: String
    return prefs.getString(_keyNombreUsuario);
  }

  /// Guarda el nombre del usuario usando setString.
  static Future<void> setNombreUsuario(String nombre) async {
    final prefs = await _getPrefs();
    // TIPO 1: String
    await prefs.setString(_keyNombreUsuario, nombre);
  }

  /// Obtiene la fecha y hora de la última apertura de la app guardada como String.
  /// Comentario intl: La librería intl se usa aquí para formatear la fecha y hora de la última apertura.
  static Future<String> getUltimaApertura() async {
    final prefs = await _getPrefs();
    // TIPO 1: String
    return prefs.getString(_keyUltimaApertura) ?? 'Primera apertura de la app';
  }

  // ===========================================================================
  // 2. TIPO INT: Objetivo Diario y Contador de Aperturas
  // ===========================================================================

  /// Obtiene el objetivo diario de hábitos guardado como int.
  /// Maneja el caso null devolviendo un valor por defecto (ej. 3).
  static Future<int> getObjetivoDiario() async {
    final prefs = await _getPrefs();
    // TIPO 2: int
    return prefs.getInt(_keyObjetivoDiario) ?? 3;
  }

  /// Guarda el objetivo diario como un entero (int).
  static Future<void> setObjetivoDiario(int objetivo) async {
    final prefs = await _getPrefs();
    // TIPO 2: int
    await prefs.setInt(_keyObjetivoDiario, objetivo);
  }

  /// Obtiene el número total de veces que se ha abierto la app (int).
  static Future<int> getContadorAperturas() async {
    final prefs = await _getPrefs();
    // TIPO 2: int
    return prefs.getInt(_keyContadorAperturas) ?? 0;
  }

  /// Registra una nueva apertura de la aplicación:
  /// Incrementa el contador de aperturas (int) y guarda la fecha/hora actual (String con intl).
  static Future<void> registrarApertura() async {
    final prefs = await _getPrefs();

    // Actualizamos el contador de aperturas (TIPO int)
    int contadorActual = prefs.getInt(_keyContadorAperturas) ?? 0;
    contadorActual++;
    await prefs.setInt(_keyContadorAperturas, contadorActual);

    // Guardamos la fecha y hora actual en formato comprensible (TIPO String con intl)
    // Comentario intl: DateFormat de intl ayuda a mostrar la fecha/hora actual con un formato legible.
    final ahora = DateTime.now();
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm:ss').format(ahora);
    await prefs.setString(_keyUltimaApertura, fechaFormateada);
  }

  // ===========================================================================
  // 3. TIPO BOOL: Tema Oscuro y Ocultar Completados
  // ===========================================================================

  /// Obtiene la preferencia del tema oscuro (bool).
  static Future<bool> getIsDarkMode() async {
    final prefs = await _getPrefs();
    // TIPO 3: bool
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  /// Guarda el estado del tema oscuro (bool).
  static Future<void> setIsDarkMode(bool isDark) async {
    final prefs = await _getPrefs();
    // TIPO 3: bool
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  /// Obtiene si se deben ocultar los hábitos ya completados hoy (bool).
  static Future<bool> getOcultarCompletados() async {
    final prefs = await _getPrefs();
    // TIPO 3: bool
    return prefs.getBool(_keyOcultarCompletados) ?? false;
  }

  /// Guarda la preferencia de ocultar hábitos completados (bool).
  static Future<void> setOcultarCompletados(bool ocultar) async {
    final prefs = await _getPrefs();
    // TIPO 3: bool
    await prefs.setBool(_keyOcultarCompletados, ocultar);
  }

  // ===========================================================================
  // 4. TIPO DOUBLE: Tamaño de Letra / Factor de Escala de Texto
  // ===========================================================================

  /// Obtiene el tamaño de letra (double) configurado por el usuario.
  /// Retorna un valor por defecto de 16.0.
  static Future<double> getTamanoLetra() async {
    final prefs = await _getPrefs();
    // TIPO 4: double
    return prefs.getDouble(_keyTamanoLetra) ?? 16.0;
  }

  /// Guarda el tamaño de letra como un valor decimal (double).
  static Future<void> setTamanoLetra(double tamano) async {
    final prefs = await _getPrefs();
    // TIPO 4: double
    await prefs.setDouble(_keyTamanoLetra, tamano);
  }

  // ===========================================================================
  // 5. TIPO LIST<STRING>: Lista de Hábitos Serializados en JSON
  // ===========================================================================

  /// Recupera la lista de hábitos guardados en SharedPreferences.
  /// Lee una lista de cadenas `List<String>` donde cada elemento es una cadena JSON que representa un Habito.
  /// Usa jsonDecode para deserializar cada elemento al objeto Habito.
  static Future<List<Habito>> getHabitos() async {
    final prefs = await _getPrefs();
    // TIPO 5: List<String>
    final List<String>? jsonList = prefs.getStringList(_keyListaHabitos);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    // Deserializamos cada String JSON a un objeto Habito
    return jsonList.map((strJson) {
      final Map<String, dynamic> map = jsonDecode(strJson);
      return Habito.fromJson(map);
    }).toList();
  }

  /// Guarda la lista completa de hábitos en SharedPreferences.
  /// Convierte cada objeto Habito a Map mediante toJson() y luego a String con jsonEncode.
  /// Finalmente guarda la lista de cadenas mediante setStringList.
  static Future<void> guardarHabitos(List<Habito> habitos) async {
    final prefs = await _getPrefs();

    // Serializamos la lista de objetos Habito a una lista de cadenas JSON (List<String>)
    final List<String> jsonList = habitos.map((habito) {
      return jsonEncode(habito.toJson());
    }).toList();

    // TIPO 5: List<String>
    await prefs.setStringList(_keyListaHabitos, jsonList);
  }

  // ===========================================================================
  // MÉTODOS DE AYUDA Y RECEPTÁCULOS DE ESTADO DE LA APLICACIÓN
  // ===========================================================================

  /// Comprueba si es la primera vez que el usuario abre la aplicación.
  static Future<bool> esPrimeraVez() async {
    final nombre = await getNombreUsuario();
    return nombre == null || nombre.trim().isEmpty;
  }

  /// Guarda los datos iniciales solicitados en la Pantalla de Bienvenida.
  static Future<void> guardarBienvenida(String nombre, int objetivo) async {
    await setNombreUsuario(nombre);
    await setObjetivoDiario(objetivo);
  }

  /// Borra todos los datos guardados en SharedPreferences.
  /// Restablece la aplicación a su estado original recién instalada.
  static Future<void> borrarTodo() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
