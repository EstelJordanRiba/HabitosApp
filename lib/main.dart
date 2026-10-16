import 'package:flutter/material.dart';
import 'screens/ajustes_screen.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/estadisticas_screen.dart';
import 'screens/principal_screen.dart';
import 'services/preferencias_service.dart';

void main() async {
  // Aseguramos la inicialización de los bindings de Flutter antes de usar SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitosApp());
}

/// Widget raíz de la aplicación HabitosApp.
/// Gestiona la carga inicial de preferencias (Tema, Tamaño de Letra y Estado de Bienvenida).
class HabitosApp extends StatefulWidget {
  const HabitosApp({super.key});

  @override
  State<HabitosApp> createState() => _HabitosAppState();
}

class _HabitosAppState extends State<HabitosApp> {
  bool _cargando = true;
  bool _esPrimeraVez = true;
  bool _isDarkMode = false;
  double _tamanoLetra = 16.0;

  @override
  void initState() {
    super.initState();
    _inicializarApp();
  }

  /// Carga inicial asíncrona de la app:
  /// 1. Registra una nueva apertura (incrementa contador int y guarda fecha/hora String).
  /// 2. Verifica si es la primera vez que se abre la app.
  /// 3. Obtiene el tema (bool) y el tamaño de letra (double).
  Future<void> _inicializarApp() async {
    // Registramos la apertura actual
    await PreferenciasService.registrarApertura();

    final primeraVez = await PreferenciasService.esPrimeraVez();
    final isDark = await PreferenciasService.getIsDarkMode();
    final tamano = await PreferenciasService.getTamanoLetra();

    if (mounted) {
      setState(() {
        _esPrimeraVez = primeraVez;
        _isDarkMode = isDark;
        _tamanoLetra = tamano;
        _cargando = false;
      });
    }
  }

  /// Recarga las configuraciones visuales (Tema y Tamaño de Letra)
  Future<void> _reloadAppSettings() async {
    final isDark = await PreferenciasService.getIsDarkMode();
    final tamano = await PreferenciasService.getTamanoLetra();
    setState(() {
      _isDarkMode = isDark;
      _tamanoLetra = tamano;
    });
  }

  /// Notifica que la pantalla de bienvenida fue completada
  void _onBienvenidaCompletada() {
    setState(() {
      _esPrimeraVez = false;
    });
  }

  /// Restablece la aplicación a su estado inicial tras borrar los datos
  void _resetApp() {
    setState(() {
      _esPrimeraVez = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Factor de escala para el texto basado en el slider de 12 a 24 px (base: 16px)
    final textScaleFactor = _tamanoLetra / 16.0;

    return MaterialApp(
      title: 'HábitosApp',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) {
        // Aplica el tamaño de texto personalizado a toda la aplicación
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child!,
        );
      },
      home: _esPrimeraVez
          ? BienvenidaScreen(
              onBienvenidaCompletada: _onBienvenidaCompletada,
            )
          : MainShell(
              onAppSettingsChanged: _reloadAppSettings,
              onResetApp: _resetApp,
            ),
    );
  }
}

/// Shell principal de navegación con barra inferior (BottomNavigationBar).
class MainShell extends StatefulWidget {
  final VoidCallback onAppSettingsChanged;
  final VoidCallback onResetApp;

  const MainShell({
    super.key,
    required this.onAppSettingsChanged,
    required this.onResetApp,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  Key _principalKey = UniqueKey();
  Key _estadisticasKey = UniqueKey();

  void _refreshScreens() {
    setState(() {
      _principalKey = UniqueKey();
      _estadisticasKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PrincipalScreen(
        key: _principalKey,
        onDataChanged: _refreshScreens,
      ),
      EstadisticasScreen(
        key: _estadisticasKey,
      ),
      AjustesScreen(
        onAppSettingsChanged: () {
          widget.onAppSettingsChanged();
          _refreshScreens();
        },
        onResetApp: widget.onResetApp,
      ),
    ];

    final List<String> titles = [
      'HábitosApp - Principal',
      'HábitosApp - Estadísticas',
      'HábitosApp - Ajustes',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        elevation: 2,
        centerTitle: true,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Refrescamos las pantallas al cambiar de pestaña para tener siempre datos actualizados
            _refreshScreens();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
