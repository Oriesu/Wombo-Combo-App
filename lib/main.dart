import 'dart:io' show Platform; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/add_players/add_players_screen.dart'; 
import 'providers/player_provider.dart';             

void main() async {
  // Configuración de debugging (nuevo método)
  debugPrint('[MAIN] Starting application...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // CONFIGURACIÓN EDGE-TO-EDGE PARA ANDROID 15+
  // Esto debe ir ANTES de cualquier otra configuración
  await setupEdgeToEdge();
  
  // Configurar orientación solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Configurar tamaño de ventana solo en escritorio
  if (!Platform.isAndroid && !Platform.isIOS) {
    await _configureWindowSize();
  }
  
  // Configurar logging para touch
  _configureTouchLogging();
  
  runApp(MyApp());
}

Future<void> setupEdgeToEdge() async {
  try {
    // Configurar colores transparentes para las barras del sistema
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,        // Transparente
      statusBarBrightness: Brightness.light,     // Iconos claros
      statusBarIconBrightness: Brightness.dark,  // Iconos oscuros
      systemNavigationBarColor: Colors.transparent,  // Transparente
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,  // Iconos oscuros
    ));
    
    // Habilitar edge-to-edge (solo en Android)
    if (Platform.isAndroid) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      
      debugPrint('[MAIN] Edge-to-edge enabled for Android');
    }
  } catch (e) {
    debugPrint('[MAIN] Error configuring edge-to-edge: $e');
  }
}

void _configureTouchLogging() {
  debugPrint('[MAIN] Touch logging enabled');
  debugPrint('[MAIN] Platform: ${Platform.operatingSystem}');
  debugPrint('[MAIN] Platform version: ${Platform.operatingSystemVersion}');
}

Future<void> _configureWindowSize() async {
  try {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      const double width = 800;
      const double height = 600;
      const double extraHeight = 500; 
      final newSize = Size(width, height + extraHeight);
      
      await windowManager.setSize(newSize);
      await windowManager.setMinimumSize(newSize);
      await windowManager.setMaximumSize(Size(width + 100, height + extraHeight + 100));
      await windowManager.center(); 
      
      print('Tamaño de ventana ajustado: ${newSize.width}x${newSize.height}');
    }
  } catch (e) {
    print('No se pudo ajustar el tamaño de ventana (normal en móvil): $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = PlayersProvider();
        // Agregar algunos logs para debug
        provider.addListener(() {
          debugPrint('[APP] PlayersProvider changed - players: ${provider.players}');
        });
        return provider;
      },
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Juego de Beber',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: false, 
              // Configurar transiciones de página globalmente
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  // Para todas las plataformas usar transiciones fade
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            home: EdgeToEdgeWrapper(
              child: AddPlayersScreen(),
            ),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Widget para detectar gestos globales
              return GestureDetector(
                onTapDown: (details) {
                  debugPrint('[APP] Global tap at ${details.globalPosition}');
                },
                behavior: HitTestBehavior.translucent,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

// Wrapper para manejar edge-to-edge en todas las pantallas
class EdgeToEdgeWrapper extends StatelessWidget {
  final Widget child;
  
  const EdgeToEdgeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: false,  // Mantener padding superior para status bar
      removeBottom: true,  // Quitar padding inferior para barra de navegación
      child: SafeArea(
        top: true,
        bottom: false,  // IMPORTANTE: no aplicar SafeArea en la parte inferior
        minimum: const EdgeInsets.only(top: 0),  // Sin margen mínimo
        child: Scaffold(
          extendBody: true,  // Para que el contenido se extienda
          extendBodyBehindAppBar: false,  // Depende de si usas AppBar
          body: child,
        ),
      ),
    );
  }
}