import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import 'wombo_combo_logic.dart';
import 'players_menu_overlay.dart';
import '../../widgets/game_board.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WomboComboLogic(players: widget.players),
      child: Scaffold(
        backgroundColor: const Color(0xFF1a0033),
        body: Consumer<WomboComboLogic>(
          builder: (context, gameLogic, child) {
            final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (playersProvider.players.isNotEmpty && 
                  !_areListsEqual(gameLogic.players, playersProvider.players)) {
                gameLogic.updatePlayers(playersProvider.players);
              }
            });
            
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1a0033), Color(0xFF330033)],
                    ),
                  ),
                ),
                
                // Contenido principal C
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header con botón Gestionar Jugadores
                              _buildHeader(gameLogic),
                              
                              const SizedBox(height: 20),
                              
                              // Información del juego
                              _buildGameInfo(gameLogic),
                              
                              const SizedBox(height: 20),
                              
                              // Contenedor del tablero y contenido
                              Container(
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
                                    GameBoard(
                                      players: gameLogic.players,
                                      playerPositions: gameLogic.playerPositions,
                                      getPlayerColor: gameLogic.getPlayerColor,
                                    ),
                                    
                                    const SizedBox(height: 15),
                                    
                                    _buildContentSection(gameLogic),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // BOTONES INFERIORES - AHORA DENTRO DEL SCROLL
                              _buildBottomButtons(context, gameLogic),
                              
                              const SizedBox(height: 40), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // OVERLAY DEL MENÚ DE JUGADORES
                if (gameLogic.showPlayersMenu)
                  _buildPlayersMenuOverlay(gameLogic, playersProvider),

                // Overlay del timer 123
                if (gameLogic.is123Active)
                  _build123TimerOverlay(gameLogic),

                // Mensaje de timeout
                if (gameLogic.showTimeoutMessage)
                  _buildTimeoutMessage(context, gameLogic),

                // Overlay de victoria
                if (gameLogic.showVictoryScreen)
                  _buildVictoryOverlay(context, gameLogic),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Widget _buildHeader(WomboComboLogic gameLogic) {
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
          
          // BOTÓN GESTIONAR JUGADORES
          ElevatedButton(
            onPressed: () {
              debugPrint('[WOMBO COMBO] Botón Gestionar Jugadores presionado');
              gameLogic.showPlayersMenu = true;
              gameLogic.notifyListeners();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              elevation: 0,
              minimumSize: const Size(200, 50),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 20),
                SizedBox(width: 10),
                Text(
                  'Gestionar Jugadores',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(WomboComboLogic gameLogic) {
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
      margin: const EdgeInsets.only(top: 15),
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
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            padding: const EdgeInsets.all(20),
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
            child: Opacity(
              opacity: gameLogic.showContent && !gameLogic.is123Active ? 1.0 : 0.0,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WomboComboLogic gameLogic) {
    final isDiceDisabled = gameLogic.isRolling || 
                          gameLogic.is123Active || 
                          gameLogic.isDiceButtonDisabled || 
                          gameLogic.showVictoryScreen;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Botón tirar dado principal 
          ElevatedButton(
            onPressed: isDiceDisabled ? null : () {
              debugPrint('[WOMBO COMBO] Botón Tirar Dado presionado');
              gameLogic.rollDice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDiceDisabled ? Colors.grey : const Color(0xFF29B6F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: isDiceDisabled ? 0 : 8,
              shadowColor: isDiceDisabled ? null : const Color(0xFF29B6F6).withOpacity(0.5),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino,
                  size: 24,
                  color: isDiceDisabled ? Colors.white70 : Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'TIRAR DADO',
                  style: TextStyle(
                    fontSize: 1.3 * 16,
                    fontWeight: FontWeight.w700,
                    color: isDiceDisabled ? Colors.white70 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Fila con dado y botón volver
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón volver
              ElevatedButton(
                onPressed: () {
                  debugPrint('[WOMBO COMBO] Botón Volver presionado');
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  elevation: 0,
                  minimumSize: const Size(120, 50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text('Volver'),
                  ],
                ),
              ),
              
              // Dado visual
              Container(
                width: 70,
                height: 70,
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
                        fontSize: 2.2 * 16,
                        fontWeight: FontWeight.bold,
                        color: gameLogic.isRolling ? Colors.white54 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Botón reiniciar
              ElevatedButton(
                onPressed: () {
                  debugPrint('[WOMBO COMBO] Botón Reiniciar presionado');
                  _showRestartConfirmation(context, gameLogic);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                  ),
                  elevation: 0,
                  minimumSize: const Size(120, 50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restart_alt, size: 20),
                    SizedBox(width: 8),
                    Text('Reiniciar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestartConfirmation(BuildContext context, WomboComboLogic gameLogic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a0044),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: const Text(
          'Reiniciar Juego',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que quieres reiniciar el juego? '
          'Se perderá el progreso actual.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              gameLogic.restartGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersMenuOverlay(WomboComboLogic gameLogic, PlayersProvider playersProvider) {
    return PlayersMenuOverlay(
      key: ValueKey('players_menu_${playersProvider.players.length}'), // Clave única para evitar reconstrucción
      players: playersProvider.players,
      newPlayerNameController: _newPlayerNameController,
      onAddPlayer: () {
        final name = _newPlayerNameController.text.trim();
        if (name.isNotEmpty) {
          playersProvider.addPlayer(name);
          gameLogic.updatePlayers(playersProvider.players);
        }
      },
      onRemovePlayer: (index) {
        playersProvider.removePlayerByIndex(index);
        gameLogic.updatePlayers(playersProvider.players);
      },
      onHideMenu: () {
        debugPrint('[WOMBO COMBO] Cerrando menú de jugadores');
        gameLogic.showPlayersMenu = false;
        gameLogic.notifyListeners();
      },
      getPlayerColor: gameLogic.getPlayerColor,
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
                onPressed: () {
                  debugPrint('[WOMBO COMBO] Botón Saltar Timer presionado');
                  gameLogic.skipTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  minimumSize: const Size(48, 48),
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

  Widget _buildTimeoutMessage(BuildContext context, WomboComboLogic gameLogic) {
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
                  debugPrint('[WOMBO COMBO] Botón Continuar (timeout) presionado');
                  gameLogic.showTimeoutMessageFlag = false;
                  gameLogic.nextPlayer();
                  gameLogic.notifyListeners();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B6F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(BuildContext context, WomboComboLogic gameLogic) {
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
                      debugPrint('[WOMBO COMBO] Botón Jugar Otra Vez presionado');
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
                      minimumSize: const Size(48, 48),
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
                    onPressed: () {
                      debugPrint('[WOMBO COMBO] Botón Volver al Menú presionado');
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFFFF6B6B).withOpacity(0.4),
                      minimumSize: const Size(48, 48),
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