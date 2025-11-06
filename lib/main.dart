import 'dart:io' show Platform; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/add_players/add_players_screen.dart'; 
import 'providers/player_provider.dart';             
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Configurar el tamaño REAL de la ventana en Linux/Desktop
  await _configureWindowSize();

  // Inicialización de Unity Ads solo en plataformas móviles (Android/iOS)
  if (Platform.isAndroid || Platform.isIOS) {
    await UnityAds.init(
      gameId: Platform.isAndroid ? '5976245' : ' 5976244 ',  
      testMode: false,
      onComplete: () => print('Inicialización de Unity Ads completa.'),
      onFailed: (error, message) => print('Inicialización de Unity Ads fallida: $message'),
    );
  }
  
  runApp(MyApp());
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
    print('No se pudo ajustar el tamaño de ventana (puede ser normal en móvil): $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayersProvider(),
      child: MaterialApp(
        title: 'Juego de Beber',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AddPlayersScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}