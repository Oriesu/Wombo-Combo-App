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
      child: MaterialApp(
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
        home: AddPlayersScreen(),
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
      ),
    );
  }
}