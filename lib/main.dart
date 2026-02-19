import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/add_players/add_players_screen.dart';
import 'providers/player_provider.dart';

// IMPORTAMOS WINDOW_MANAGER AQUÍ (en la parte superior)
// Pero solo lo usaremos cuando estemos en desktop
import 'package:window_manager/window_manager.dart' as wm;

void main() async {
  debugPrint('[MAIN] Starting application...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // CONFIGURACIÓN EDGE-TO-EDGE
  await setupEdgeToEdge();
  
  // Configurar orientación
  await _configureOrientation();

  // CONFIGURAR WINDOW MANAGER - SOLO DESKTOP
  await _configureWindowSizeSafe();
  
  runApp(const MyApp());
}

Future<void> _configureOrientation() async {
  try {
    if (Platform.isIOS) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  } catch (e) {
    debugPrint('Error configurando orientación: $e');
  }
}

Future<void> setupEdgeToEdge() async {
  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
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

// VERSIÓN CORREGIDA - Sin imports dinámicos
Future<void> _configureWindowSizeSafe() async {
  final bool isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
  
  if (isDesktop) {
    try {
      // En desktop, usamos window_manager directamente
      // Como ya está importado arriba, podemos usarlo sin problemas
      await wm.windowManager.ensureInitialized();
      
      const double width = 800;
      const double height = 600;
      const double extraHeight = 500;
      const newSize = Size(width, height + extraHeight);
      
      await wm.windowManager.setSize(newSize);
      await wm.windowManager.setMinimumSize(newSize);
      await wm.windowManager.setMaximumSize(const Size(width + 100, height + extraHeight + 100));
      await wm.windowManager.center();
      
      debugPrint('[MAIN] Tamaño de ventana ajustado');
    } catch (e) {
      debugPrint('[MAIN] Error en configuración de ventana: $e');
    }
  } else {
    debugPrint('[MAIN] No es desktop, omitiendo configuración de ventana');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayersProvider(),
      child: MaterialApp(
        title: 'Wombo Combo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: false,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const SafeArea(
          top: true,
          bottom: false,
          child: Scaffold(
            extendBody: true,
            body: AddPlayersScreen(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}