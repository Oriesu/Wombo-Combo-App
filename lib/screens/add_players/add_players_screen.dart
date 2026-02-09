// Archivo: lib/screens/add_players/add_players_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importar para SystemChrome
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

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({Key? key}) : super(key: key);

  @override
  _AddPlayersScreenState createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController playerNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Configurar SystemUI para prevenir flash blanco
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1a0033),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    playerNameController.dispose();
    _scrollController.dispose();
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

  void _startGameWithTransition(String gameType, Widget screen) {
    // Asegurar SystemUI antes de navegar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1a0033),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Transición fade sin fondo blanco - MÁS RÁPIDA
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200), // ← Más rápido
        reverseTransitionDuration: const Duration(milliseconds: 200), // ← También al volver
      ),
    );
  }

  void startGame(String gameType, PlayersProvider playersProvider) {
    if (!canStartGame(gameType, playersProvider)) {
      showNotEnoughPlayersMessage(context);
      return;
    }

    final players = playersProvider.players;
    
    switch(gameType) {
      case 'yo-nunca':
        _startGameWithTransition(
          gameType,
          YoNuncaScreen(players: players),
        );
        break;
      case 'wombo-combo':
        _startGameWithTransition(
          gameType,
          WomboComboScreen(players: players),
        );
        break;
      case 'terribles-decisiones':
        _startGameWithTransition(
          gameType,
          TerriblesDecisionesScreen(players: players),
        );
        break;
      case 'quien-mas-probable':
        _startGameWithTransition(
          gameType,
          QuienMasProbableScreen(players: players),
        );
        break;
      case 'verdad-reto': 
        _startGameWithTransition(
          gameType,
          VerdadRetoScreen(players: players),
        );
        break;
      case 'versus':
        _startGameWithTransition(
          gameType,
          VersusScreen(players: players),
        );
        break;
      case 'caballos':
        _startGameWithTransition(
          gameType,
          CaballosScreen(players: players),
        );
        break;
      case 'ruleta':
        _startGameWithTransition(
          gameType,
          RuletaScreen(players: players),
        );
        break;
      case '123':
        _startGameWithTransition(
          gameType,
          OneTwoThreeScreen(players: players),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modo de juego no disponible aún')),
        );
    }
  }

  Widget _buildRuletaIcon() {
    return Container(
      width: 32, 
      height: 32,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/casino-roulette.png',
        width: 32,  
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            '🎰',
            style: TextStyle(fontSize: 24),
          );
        },
      ),
    );
  }
  
  Widget _build123Icon() {
    return Container(
      width: 32, 
      height: 32,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/podium.png',
        width: 32,  
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            '🔢',
            style: TextStyle(fontSize: 24),
          );
        },
      ),
    );
  }
  

  Widget _buildGameModeCard({
    required String icon,
    required String name,
    required bool enabled,
    required String gameType,
    required PlayersProvider playersProvider,
    bool fullWidth = false,
  }) {

    bool isQuienMasProbable = name.contains('Quién es más probable');
    
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
              if (gameType == 'ruleta')
                _buildRuletaIcon()  
              else
              if (gameType == '123')
                _build123Icon()  
              else
                Text( 
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isQuienMasProbable ? 10 : 12,
                  height: 1.2,
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
                  name: '3, 2, 1...¡Bebe!',
                  enabled: playersProvider.players.length >= 2,
                  gameType: '123',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🎰',  // Este será reemplazado por la imagen
                  name: 'Ruleta de tragos',
                  enabled: playersProvider.players.length >= 2,
                  gameType: 'ruleta',  // Importante: gameType = 'ruleta'
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

  Widget _buildWarningText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Text(
        "Esta app contiene temas para adultos y referencias al alcohol. Está destinada solo a mayores de edad (+18)",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0033),
      // IMPORTANTE: Esto ayuda a prevenir flash blanco durante transiciones
      extendBodyBehindAppBar: true,
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
              child: Column(
                children: [

                  const SizedBox(height: 30),
              
                  // Contenido principal con ScrollView que incluye el warning al final
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final playersProvider = Provider.of<PlayersProvider>(context, listen: true);
                        final players = playersProvider.players;
                        
                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
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
                                              hintText: 'Añadir nombres',
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

                                    if (!players.isEmpty) ...[
                                      const SizedBox(height: 20),    
                                   ],

                                    // Lista de jugadores
                                    Container(
                                      constraints: const BoxConstraints(maxHeight: 150),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: players.map((player) => PlayerTag(
                                                onRemove: () => _removePlayer(player),
                                                playerName: player,
                                              )).toList(),
                                            ), const SizedBox(height: 10),

                                            // Texto informativo añadido aquí
                                            if (players.isEmpty) ...[
                                              const SizedBox(height: 15),
                                              const Text(
                                                "Agrega los nombres de los jugadores para desbloquear los modos de juego",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
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
                              Column(
                                children: [
                                  // Grid de modos de juego
                                  _buildGameModesGrid(playersProvider),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Texto de advertencia (ahora dentro del scroll)
                                  _buildWarningText(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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