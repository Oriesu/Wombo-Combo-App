import 'dart:async';                          
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/add_players/add_players_screen.dart';
import 'providers/player_provider.dart';
import 'package:window_manager/window_manager.dart' as wm;

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupEdgeToEdge();
    await _configureOrientation();
    await _configureWindowSizeSafe();
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('ERROR FATAL EN MAIN: $error\n$stack');
  });
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
      debugPrint('[MAIN] Edge-to-edge habilitado para Android');
    }
  } catch (e) {
    debugPrint('[MAIN] Error configurando edge-to-edge: $e');
  }
}

Future<void> _configureWindowSizeSafe() async {
  final bool isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
  
  if (isDesktop) {
    try {
      await wm.windowManager.ensureInitialized();
      const double width = 800;
      const double height = 600;
      const double extraHeight = 500;
      const newSize = Size(width, height + extraHeight);
      
      await wm.windowManager.setSize(newSize);
      await wm.windowManager.setMinimumSize(newSize);
      await wm.windowManager.setMaximumSize(const Size(width + 100, height + extraHeight + 100));
      await wm.windowManager.center();
      debugPrint('[MAIN] Tamaño de ventana ajustado para desktop');
    } catch (e) {
      debugPrint('[MAIN] Error en configuración de ventana: $e');
    }
  } else {
    debugPrint('[MAIN] No es desktop, omitiendo window_manager');
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