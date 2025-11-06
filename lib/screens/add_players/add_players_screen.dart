// Archivo: lib/screens/add_players/add_players_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../yo_nunca/yo_nunca_screen.dart';
import '../terribles_decisiones/terribles_decisiones_screen.dart';  
import '../wombo_combo/wombo_combo_screen.dart';
import '../quien_mas_probable/quien_mas_probable_screen.dart';
import '../../providers/player_provider.dart';
import '../../widgets/player_tag.dart';
import '../verdad_reto/verdad_reto_screen.dart';
import '../versus/versus_screen.dart';
import '../caballos/caballos_screen.dart';
import '../ruleta/ruleta_screen.dart';
import '../123/123_screen.dart';
import 'add_players_logic.dart';

// Imports necesarios para anuncios y plataforma
import 'dart:io' show Platform;
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// ***** 1. AÑADE ESTE IMPORT *****
import 'package:app_tracking_transparency/app_tracking_transparency.dart';


class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({Key? key}) : super(key: key);

  @override
  _AddPlayersScreenState createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController playerNameController = TextEditingController();

  // ⚠️ REEMPLAZAR ESTOS IDs POR LOS DE TU PROYECTO DE UNITY ADS
  String get bannerPlacementId => Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS';
  String get interstitialPlacementId => Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS';

  // Variable para controlar que el anuncio no salte al abrir la app
  bool isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Pre-cargamos el primer anuncio intersticial
    _loadInterstitialAd();

    // ***** 2. AÑADE ESTA LLAMADA A LA FUNCIÓN *****
    // Usamos un pequeño retraso para asegurar que la app esté visible
    // antes de mostrar el pop-up de permisos de iOS.
    Future.delayed(const Duration(seconds: 2), () {
      _requestATT();
    });
  }
  
  // ***** 3. AÑADE ESTA NUEVA FUNCIÓN COMPLETA *****
  Future<void> _requestATT() async {
    // Esta función solo hará algo en dispositivos iOS.
    // En Android, no hará nada.
    if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.notDetermined) {
      // Muestra el pop-up de solicitud.
      // El mensaje que se muestra es el que escribiste en Info.plist.
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      print("Estado del permiso ATT: $status");
    }
  }

  void _loadInterstitialAd() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Usar Future.delayed para asegurar que Unity Ads esté completamente inicializado
      Future.delayed(Duration(milliseconds: 500), () {
        UnityAds.load(placementId: interstitialPlacementId);
      });
    }
  }

  void _showInterstitialAd() {
    // 1. Lógica para saltar el anuncio si es la primera vez que se abre la app
    if (isFirstLoad) {
      print("Primera carga, no se muestra el intersticial.");
      // Se marca como false para que el siguiente regreso sí lo muestre
      isFirstLoad = false; 
      return; 
    }

    // 2. Mostrar el anuncio si no es la primera carga y estamos en móvil
    if (Platform.isAndroid || Platform.isIOS) {
      UnityAds.showVideoAd(
        placementId: interstitialPlacementId,
        onComplete: (placementId) {
          print('Anuncio $placementId completado');
          _loadInterstitialAd(); // Pre-cargamos el siguiente para la próxima vuelta
        },
        onFailed: (placementId, error, message) {
          print('Error al mostrar $placementId: $message');
          _loadInterstitialAd(); // Pre-cargamos el siguiente igualmente
        },
      );
    }
  }

  @override
  void dispose() {
    playerNameController.dispose();
    super.dispose();
  }

  bool canStartGame(String gameType, PlayersProvider playersProvider) {
    final players = playersProvider.players;
    
    switch(gameType) {
    case 'yo-nunca':
    case 'quien-mas-probable':
    case 'caballos':
    case 'terribles-decisiones':
      return players.length >= 0;
    case 'wombo-combo':
    case 'verdad-reto':
    case '123':
    case 'ruleta':
      return players.length >= 2; 
    case 'versus':
      return players.length >= 4;
    default:
      return false;
  }
  }
  

  void showNotEnoughPlayersMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se necesitan al menos 2 jugadores para este juego'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addPlayer(PlayersProvider playersProvider, BuildContext context) {
    final name = playerNameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre')),
      );
      return;
    }
    
    if (playersProvider.players.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nombre ya existe')),
      );
      return;
    }
    
    if (name.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede tener más de 15 caracteres')),
      );
      return;
    }
    
    playersProvider.addPlayer(name);
    playerNameController.clear();
    setState(() {});
  }

  void _removePlayer(String player) {
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    playersProvider.removePlayer(player);
    setState(() {});
  }

  void startGame(String gameType, PlayersProvider playersProvider) {
    if (!canStartGame(gameType, playersProvider)) {
      showNotEnoughPlayersMessage(context);
      return;
    }

    final players = playersProvider.players;
    
    // Función helper: Se ejecuta cuando se vuelve a esta pantalla (el "pop" del Navigator)
    final onGameEnd = (_) => _showInterstitialAd();

    // ***** MODIFICACIÓN CRÍTICA: Se añade el .then(onGameEnd) a TODOS los pushes *****
    switch(gameType) {
      case 'yo-nunca':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YoNuncaScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'wombo-combo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WomboComboScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'terribles-decisiones':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TerriblesDecisionesScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'quien-mas-probable':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuienMasProbableScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'verdad-reto': 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerdadRetoScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'versus':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VersusScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'caballos':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaballosScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      case 'ruleta':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RuletaScreen(players: players),
          ),
        ).then(onGameEnd);
      case '123':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OneTwoThreeScreen(players: players),
          ),
        ).then(onGameEnd); 
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modo de juego no disponible aún')),
        );
    }
  }

  Widget _buildGameModeCard({
    required String icon,
    required String name,
    required bool enabled,
    required String gameType,
    required PlayersProvider playersProvider,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: enabled ? () => startGame(gameType, playersProvider) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(enabled ? 0.2 : 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModesGrid(PlayersProvider playersProvider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Fila 1
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🙅‍♂️',
                  name: 'Yo Nunca',
                  enabled: true,
                  gameType: 'yo-nunca',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🤔',
                  name: '¿Quién es más probable?',
                  enabled: true,
                  gameType: 'quien-mas-probable',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Fila 2
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🗳️',
                  name: 'Terribles decisiones',
                  enabled: true,
                  gameType: 'terribles-decisiones',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🐎',
                  name: 'Carrera de Caballos',
                  enabled: true,
                  gameType: 'caballos',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Fila 3
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '⚔️',
                  name: 'Versus (4 jugadores)',
                  enabled: playersProvider.players.length >= 4,
                  gameType: 'versus',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '❓',
                  name: 'Verdad o Reto',
                  enabled: playersProvider.players.length >= 2,
                  gameType: 'verdad-reto',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Fila 4
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🔢',
                  name: '1, 2, 3',
                  enabled: playersProvider.players.length >= 2,
                  gameType: '123',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🎰',
                  name: 'Ruleta de tragos',
                  enabled: playersProvider.players.length >= 2,
                  gameType: 'ruleta',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Fila 5
          _buildGameModeCard(
            icon: '🌀',
            name: 'Wombo Combo',
            enabled: playersProvider.players.length >= 2,
            gameType: 'wombo-combo',
            playersProvider: playersProvider,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0033),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0033), Color(0xFF330033)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Contenido principal de la app
                  Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Agrega Jugadores',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                  
                      // Contenido scrollable
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final playersProvider = Provider.of<PlayersProvider>(context, listen: true);
                            final players = playersProvider.players;
                            
                            return Column(
                              children: [
                                // Input para agregar jugador
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: playerNameController,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                hintText: 'Nombre del jugador',
                                                hintStyle: const TextStyle(color: Colors.white54),
                                                filled: true,
                                                fillColor: Colors.white.withOpacity(0.1),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                              ),
                                              onSubmitted: (_) => addPlayer(playersProvider, context),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () => addPlayer(playersProvider, context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF29B6F6),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 4,
                                            ),
                                            child: const Text(
                                              'Agregar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                  
                                      // Lista de jugadores
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 150),
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: players.map((player) => PlayerTag(
                                              onRemove: () => _removePlayer(player),
                                              playerName: player,
                                            )).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                  
                                const SizedBox(height: 20),
                                
                                // Divider
                                Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.2),
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                ),
                  
                                // Sección de modos de juego
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        // Título modos de juego
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Elige Modo con Jugadores (${players.length}/2+)',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                  
                                        // Grid de modos de juego
                                        _buildGameModesGrid(playersProvider),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  
                      // Texto de advertencia
                      const Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 5),
                        child: Text(
                          "Esta app contiene temas para adultos y referencias al alcohol. Está destinada solo a mayores de edad (+18)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      // Espacio reservado para el banner en la parte inferior.
                      const SizedBox(height: 50),
                    ],
                  ),

                  // Banner de Unity Ads alineado en la parte inferior del Stack
                  if (Platform.isAndroid || Platform.isIOS)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: UnityBannerAd(
                        placementId: bannerPlacementId,
                        onLoad: (placementId) => print('Banner cargado: $placementId'),
                        onClick: (placementId) => print('Banner clicado: $placementId'),
                        onFailed: (placementId, error, message) => print('Error en Banner $placementId: $message'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}