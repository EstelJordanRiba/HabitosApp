import 'package:flutter/material.dart';
import 'screens/ajustes_screen.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/estadisticas_screen.dart';
import 'screens/principal_screen.dart';
import 'services/preferencias_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitosApp());
}

// Widget principal que maneja el tema y el estado de carga inicial de la aplicación
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

  // Carga inicial de preferencias (Aperturas, Tema y Tamaño de texto)
  Future<void> _inicializarApp() async {
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

  // Recarga el tema y el tamaño de letra si han cambiado en Ajustes
  Future<void> _reloadAppSettings() async {
    final isDark = await PreferenciasService.getIsDarkMode();
    final tamano = await PreferenciasService.getTamanoLetra();
    setState(() {
      _isDarkMode = isDark;
      _tamanoLetra = tamano;
    });
  }

  void _onBienvenidaCompletada() {
    setState(() {
      _esPrimeraVez = false;
    });
  }

  void _resetApp() {
    setState(() {
      _esPrimeraVez = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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

// Estructura de navegación principal con barra inferior
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

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
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
