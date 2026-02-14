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
  
  // Lista de iconos disponibles para los jugadores
  static const List<String> _playerIcons = [
    'aguardiente.png',
    'amaretto-sour.png',
    'anis.png',
    'cerveza-negra.png',
    'champagne.png',
    'conac.png',
    'gin-tonic.png',
    'glass.png',
    'jagermeister.png',
    'kahlua.png',
    'limoncello.png',
    'mojito.png',
    'orujo.png',
    'rum.png',
    'sangria.png',
    'sidra.png',
    'vermut.png',
    'vodka.png',
    'whiskey.png',
    'wine-bottle.png',
  ];

  // Función para obtener la ruta del icono de un jugador
  String _getPlayerIconPath(int playerIndex) {
    final iconIndex = playerIndex % _playerIcons.length;
    return 'lib/screens/wombo_combo/iconos/${_playerIcons[iconIndex]}';
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WomboComboLogic(players: widget.players),
      child: Scaffold(
        backgroundColor: const Color(0xFF1a0033),
        body:Consumer<WomboComboLogic>(
          builder: (context, gameLogic, child) {
            final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
            
            // Solo actualizar si realmente cambió la lista de jugadores
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
                
                // Contenido principal
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header con botón Gestionar Jugadores
                              _buildHeader(gameLogic),
                              
                              const SizedBox(height: 16),
                              
                              // Información del juego
                              _buildGameInfo(gameLogic),
                              
                              const SizedBox(height: 16),
                              
                              // Tablero
                              GameBoard(
                                players: gameLogic.players,
                                playerPositions: gameLogic.playerPositions,
                                getPlayerColor: gameLogic.getPlayerColor,
                                boardConfig: gameLogic.boardConfig,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              _buildBottomButtons(context, gameLogic),
                              
                              const SizedBox(height: 20), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // OVERLAY DEL DADO
                if (gameLogic.showDiceOverlay)
                  _buildDiceOverlay(gameLogic),

                // OVERLAY DEL MENÚ DE JUGADORES
                if (gameLogic.showPlayersMenu)
                  _buildPlayersMenuOverlay(gameLogic, playersProvider),

                // Overlay del timer 3, 2, 1...¡Bebe!
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'Wombo Combo',
            style: TextStyle(
              fontSize: 28,
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
          const SizedBox(height: 12),
          
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              elevation: 0,
              minimumSize: const Size(200, 44),
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
                  // Icono del jugador (sin forma circular)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      _getPlayerIconPath(gameLogic.currentPlayerIndex),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          color: gameLogic.getPlayerColor(gameLogic.currentPlayerIndex),
                        );
                      },
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

  Widget _buildBottomButtons(BuildContext context, WomboComboLogic gameLogic) {
    final isDiceDisabled = gameLogic.isRolling || 
                          gameLogic.is123Active || 
                          gameLogic.isDiceButtonDisabled || 
                          gameLogic.showVictoryScreen ||
                          gameLogic.players.isEmpty;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BOTÓN VOLVER
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
              minimumSize: const Size(100, 50),
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
          
          // DADO IMAGEN CLICKEABLE 
          GestureDetector(
            onTap: isDiceDisabled ? null : () {
              debugPrint('[WOMBO COMBO] Dado pulsado para tirar');
              gameLogic.rollDice();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80, 
              height: 80,
              padding: const EdgeInsets.all(8), 
              child: Center(
                child: _buildDiceImage(gameLogic), 
              ),
            ),
          ),
          
          // TEXTO INDICADOR 
          Container(
            width: 100, 
            child: Center(
              child: Text(
                isDiceDisabled ? 'Espera...' : 'Toca el dado\npara tirar',
                style: TextStyle(
                  fontSize: 14,
                  color: isDiceDisabled ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceImage(WomboComboLogic gameLogic) {
    if (gameLogic.isRolling) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _buildDiceImageWidget(gameLogic.diceValue, true),
      );
    } else {
      return _buildDiceImageWidget(gameLogic.diceValue, false);
    }
  }

  Widget _buildDiceImageWidget(int value, bool isRolling) {
    final path = _getDiceImagePath(value);
    
    return Image.asset(
      path,
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[DICE] ERROR loading image: $error');
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDiceImagePath(int value) {
    return 'lib/screens/wombo_combo/dados/dado$value.png';
  }

  Widget _buildDiceOverlay(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: GestureDetector(
        onTap: () {
          debugPrint('[WOMBO COMBO] Overlay tocado, cerrándolo');
          gameLogic.hideDiceOverlay();
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: SingleChildScrollView( 
              child: GestureDetector(
                onTap: () {}, 
                child: Container(
                  width: 400,
                  constraints: const BoxConstraints(maxWidth: 400), 
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a0044),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF29B6F6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      // Indicador de tocar para cerrar
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Toca en cualquier lado para continuar',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      // Jugador actual con su posición
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icono del jugador (sin forma circular)
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.asset(
                                _getPlayerIconPath(gameLogic.currentPlayerIndex),
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 24,
                                    height: 24,
                                    color: gameLogic.getPlayerColor(gameLogic.currentPlayerIndex),
                                  );
                                },
                              ),
                            ),
                            
                            // Nombre del jugador
                            Text(
                              gameLogic.diceOverlayPlayerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            // Separador
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: const Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            
                            // Posición del jugador
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00CCFF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF00CCFF).withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Casilla ${gameLogic.diceOverlayPlayerPosition}',
                                style: const TextStyle(
                                  color: Color(0xFF00CCFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Título del modo
                      Text(
                        gameLogic.diceOverlayTitle,
                        style: const TextStyle(
                          fontSize: 32,
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
                      
                      const SizedBox(height: 20),
                      
                      // Contenido principal 
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxHeight: 300, 
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: SingleChildScrollView( 
                          child: Text(
                            gameLogic.diceOverlayContent,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Explicación
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CC55).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00CC55).withOpacity(0.3)),
                        ),
                        child: Text(
                          gameLogic.diceOverlayExplanation,
                          style: const TextStyle(
                            fontSize: 19.2,
                            color: Color(0xFF00CC55),
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersMenuOverlay(WomboComboLogic gameLogic, PlayersProvider playersProvider) {
    return PlayersMenuOverlay(
      key: ValueKey('players_menu_${playersProvider.players.length}'),
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
      getPlayerIconPath: _getPlayerIconPath, // Pasamos la función al overlay
    );
  }

  Widget _build123TimerOverlay(WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: GestureDetector(
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {}, 
                child: Container(
                  width: 400,
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a0044),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF29B6F6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29B6F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Jugador actual con su posición
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icono del jugador (sin forma circular)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              _getPlayerIconPath(gameLogic.currentPlayerIndex),
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 24,
                                  color: gameLogic.getPlayerColor(gameLogic.currentPlayerIndex),
                                );
                              },
                            ),
                          ),
                          
                          // Nombre del jugador
                          Text(
                            gameLogic.currentPlayerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          // Separador
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          
                          // Posición del jugador
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00CCFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00CCFF).withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Casilla ${gameLogic.currentPlayerPosition}',
                              style: const TextStyle(
                                color: Color(0xFF00CCFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Título del modo
                    const Text(
                      '3, 2, 1...¡Bebe!',
                      style: TextStyle(
                        fontSize: 32,
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
                    
                    const SizedBox(height: 20),
                    
                    // Contenido del desafío
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 200, 
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: SingleChildScrollView( 
                        child: Text(
                          gameLogic.currentContent,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFFFFC107),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Explicación - Estado inicial
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CC55).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00CC55).withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '¡Di 3 cosas rápidamente!',
                            style: TextStyle(
                              fontSize: 19.2,
                              color: Color(0xFF00CC55),
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Timer o botón de inicio (según el estado)
                    if (gameLogic.timeLeft123 == 10) 
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('[WOMBO COMBO] Botón Empezar Timer presionado');
                          gameLogic.start123Timer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00CCFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text(
                          'Empezar Timer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                Text(
                                  gameLogic.timeLeft123.toString(),
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w800,
                                    color: gameLogic.timeLeft123 <= 3 
                                        ? const Color(0xFFFF6B6B)
                                        : const Color(0xFF29B6F6),
                                    shadows: [
                                      Shadow(
                                        blurRadius: 20,
                                        color: (gameLogic.timeLeft123 <= 3 
                                            ? const Color(0xFFFF6B6B)
                                            : const Color(0xFF29B6F6)).withOpacity(0.7),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'segundos restantes',
                                  style: TextStyle(
                                    fontSize: 19.2,
                                    color: gameLogic.timeLeft123 <= 3 
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Botón para saltar/salir del timer
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTimeoutMessage(BuildContext context, WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: SingleChildScrollView(
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
                const Text(
                  '¡Se acabó el tiempo!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bebe por cada una que no dijiste',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () {
                    debugPrint('[WOMBO COMBO] Botón Continuar (timeout) presionado');
                    gameLogic.showTimeoutMessageFlag = false;
                    gameLogic.nextPlayer();
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
      ),
    );
  }

  Widget _buildVictoryOverlay(BuildContext context, WomboComboLogic gameLogic) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxWidth: 400), 
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
                    fontSize: 40,
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
                    fontSize: 28.8,
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
      ),
    );
  }

  @override
  void dispose() {
    _newPlayerNameController.dispose();
    super.dispose();
  }
}