// Archivo: lib/screens/wombo_combo/wombo_combo_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../data/game_data.dart';
import 'wombo_combo_logic.dart';
import 'players_menu_overlay.dart';
import '../../widgets/game_board.dart';

// ***** MODIFICACIÓN AQUÍ: Se importa add_players_screen para el pop (aunque no es estrictamente necesario, es buena práctica)
import '../add_players/add_players_screen.dart';


class WomboComboScreen extends StatefulWidget {
  final List<String> players;
  
  const WomboComboScreen({
    Key? key,
    required this.players,
  }) : super(key: key);

  @override
  State<WomboComboScreen> createState() => _WomboComboScreenState();
}

class _WomboComboScreenState extends State<WomboComboScreen> {
  final TextEditingController _newPlayerNameController = TextEditingController();
  late WomboComboLogic gameLogic;

  @override
  void initState() {
    super.initState();
    gameLogic = WomboComboLogic(players: widget.players);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameLogic,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a0033),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a0033), Color(0xFF330033)],
            ),
          ),
          child: Consumer2<WomboComboLogic, PlayersProvider>(
            builder: (context, gameLogic, playersProvider, child) {
              // Actualizar jugadores de forma segura
              if (playersProvider.players.isNotEmpty) {
                gameLogic.updatePlayers(playersProvider.players);
              }
              
              return Stack(
                children: [
                  // Contenido principal
                  _buildFullHeightWebLayout(context, gameLogic),
                  
                  // Overlay del menú de jugadores
                  if (gameLogic.showPlayersMenu)
                    PlayersMenuOverlay(
                      players: playersProvider.players,
                      newPlayerNameController: _newPlayerNameController,
                      onAddPlayer: () {
                        final name = _newPlayerNameController.text.trim();
                        if (name.isNotEmpty) {
                          playersProvider.addPlayer(name);
                          _newPlayerNameController.clear();
                        }
                      },
                      onRemovePlayer: (index) {
                        playersProvider.removePlayerByIndex(index);
                      },
                      onHideMenu: () {
                        gameLogic.showPlayersMenu = false;
                        gameLogic.notifyListeners();
                      },
                      getPlayerColor: gameLogic.getPlayerColor,
                    ),

                  // Overlay del timer 123
                  if (gameLogic.is123Active)
                    _build123TimerOverlay(gameLogic),

                  // Mensaje de timeout
                  if (gameLogic.showTimeoutMessage)
                    _buildTimeoutMessage(gameLogic),

                  // Overlay de victoria
                  if (gameLogic.showVictoryScreen)
                    _buildVictoryOverlay(gameLogic),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeightWebLayout(BuildContext context, WomboComboLogic gameLogic) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Header
              _buildWebHeader(gameLogic),
              
              const SizedBox(height: 20),
              
              // Información del juego
              _buildGameInfoWeb(gameLogic),
              
              const SizedBox(height: 20),
              
              // Contenedor del tablero y contenido
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tablero
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: GameBoard(
                            players: gameLogic.players,
                            playerPositions: gameLogic.playerPositions,
                            getPlayerColor: gameLogic.getPlayerColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Contenido
                      if (gameLogic.showContent && !gameLogic.is123Active)
                        _buildContentSection(gameLogic),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sección del dado
              _buildDiceSectionWeb(gameLogic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(WomboComboLogic gameLogic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          const Text(
            'Wombo Combo',
            style: TextStyle(
              fontSize: 2.4 * 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton(
              onPressed: () {
                gameLogic.showPlayersMenu = true;
                gameLogic.notifyListeners();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 8),
                  Text('Gestionar Jugadores'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoWeb(WomboComboLogic gameLogic) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          // Turno del jugador
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x26FFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFCC00),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCC00).withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Turno de:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          gameLogic.currentPlayerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFCC00),
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Color(0x26FFCC00),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Posición del jugador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x2600CCFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Casilla:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  gameLogic.currentPlayerPosition.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00CCFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(WomboComboLogic gameLogic) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              gameLogic.currentContent,
              style: const TextStyle(
                fontSize: 1.2 * 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSectionWeb(WomboComboLogic gameLogic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón volver
          ElevatedButton(
            // ***** MODIFICACIÓN CRÍTICA: Se usa pop para activar el intersticial *****
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 18),
                SizedBox(width: 8),
                Text('Volver'),
              ],
            ),
          ),
          
          // Dado
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  gameLogic.isRolling ? '?' : gameLogic.diceValue.toString(),
                  key: ValueKey(gameLogic.isRolling),
                  style: TextStyle(
                    fontSize: 2.5 * 16,
                    fontWeight: FontWeight.bold,
                    color: gameLogic.isRolling ? Colors.white54 : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          // Botón tirar dado
          ElevatedButton(
            onPressed: gameLogic.isRolling || gameLogic.is123Active || gameLogic.isDiceButtonDisabled || gameLogic.showVictoryScreen
                ? null
                : gameLogic.rollDice,
            style: ElevatedButton.styleFrom(
              backgroundColor: gameLogic.isRolling || gameLogic.is123Active || gameLogic.isDiceButtonDisabled || gameLogic.showVictoryScreen
                  ? Colors.grey
                  : const Color(0xFF29B6F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 6,
              shadowColor: const Color(0x4D29B6F6),
            ),
            child: const Text(
              'Tirar Dado',
              style: TextStyle(
                fontSize: 1.2 * 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build123TimerOverlay(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF2a0044),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  gameLogic.timeLeft123.toString(),
                  style: TextStyle(
                    fontSize: 6 * 16,
                    fontWeight: FontWeight.w800,
                    color: gameLogic.timeLeft123 <= 5 
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF29B6F6),
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: (gameLogic.timeLeft123 <= 5 
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF29B6F6)).withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Label
              const Text(
                'segundos restantes',
                style: TextStyle(
                  fontSize: 1.5 * 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 25),
              
              // Texto del desafío
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  gameLogic.currentContent,
                  style: const TextStyle(
                    fontSize: 1.3 * 16,
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Botón saltar
              ElevatedButton(
                onPressed: gameLogic.skipTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
                child: const Text(
                  'Saltar Timer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeoutMessage(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameLogic.currentContent,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: () {
                  gameLogic.showTimeoutMessageFlag = false;
                  gameLogic.nextPlayer();
                  gameLogic.notifyListeners();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF2a0044),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉",
                style: TextStyle(fontSize: 80),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '¡Felicidades!',
                style: TextStyle(
                  fontSize: 2.5 * 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFCC00),
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 15),
              
              Text(
                '${gameLogic.currentPlayerName} ha ganado la partida',
                style: const TextStyle(
                  fontSize: 1.8 * 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón "Jugar Otra Vez"
                  ElevatedButton(
                    onPressed: () {
                      gameLogic.restartGameFromVictory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC55),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFF00CC55).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Jugar Otra Vez',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Botón "Volver al Menú"
                  ElevatedButton(
                    // ***** MODIFICACIÓN CRÍTICA: Se usa pop para activar el intersticial *****
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFFFF6B6B).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '¡Gracias por jugar Wombo Combo!',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPlayerNameController.dispose();
    super.dispose();
  }
}