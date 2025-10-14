import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../data/game_data.dart';
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
        body: Consumer2<WomboComboLogic, PlayersProvider>(
          builder: (context, gameLogic, playersProvider, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              gameLogic.updatePlayers(playersProvider.players);
            });
            
            return Stack(
              children: [
                // Contenido principal - Layout compacto original
                _buildCompactLayout(context, gameLogic),
                
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, WomboComboLogic gameLogic) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header compacto
          _buildCompactHeader(gameLogic),
          
          const SizedBox(height: 10),
          
          // Tablero - Ocupa la mayor parte del espacio
          Expanded(
            child: GameBoard(
              players: gameLogic.players,
              playerPositions: gameLogic.playerPositions,
              getPlayerColor: gameLogic.getPlayerColor,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Sección de contenido (solo cuando hay contenido)
          if (gameLogic.showContent && !gameLogic.is123Active)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                gameLogic.currentContent,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Sección inferior compacta
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Botón volver pequeño
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                
                const Spacer(),
                
                // Dado compacto
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      gameLogic.isRolling ? '?' : gameLogic.diceValue.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gameLogic.isRolling ? Colors.white54 : Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Botón tirar dado compacto
                ElevatedButton(
                  onPressed: gameLogic.isRolling || gameLogic.is123Active || gameLogic.isDiceButtonDisabled
                      ? null
                      : gameLogic.rollDice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gameLogic.isRolling || gameLogic.is123Active || gameLogic.isDiceButtonDisabled
                        ? Colors.grey
                        : const Color(0xFFCC00FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tirar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(WomboComboLogic gameLogic) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wombo Combo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              // Botón pequeño para gestión de jugadores
              ElevatedButton(
                onPressed: () {
                  gameLogic.showPlayersMenu = true;
                  gameLogic.notifyListeners();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                child: const Icon(Icons.people, size: 18),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Información del jugador compacta
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: gameLogic.getPlayerColor(gameLogic.currentPlayerIndex),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Turno: ${gameLogic.currentPlayerName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Casilla: ${gameLogic.currentPlayerPosition}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Los overllays del timer y timeout se mantienen igual
  Widget _build123TimerOverlay(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameLogic.timeLeft123.toString(),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    color: gameLogic.timeLeft123 <= 5 
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF00CCFF),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'segundos restantes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameLogic.currentContent,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFCC00),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: gameLogic.skipTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Saltar Timer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoutMessage(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameLogic.currentContent,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 15),
              
              ElevatedButton(
                onPressed: () {
                  gameLogic.showTimeoutMessageFlag = false;
                  gameLogic.nextPlayer();
                  gameLogic.notifyListeners();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6B6B),
                ),
                child: const Text('Continuar'),
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