import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../data/game_data.dart';
import '../../widgets/game_board.dart'; 
import 'dart:async';    
import 'dart:math';     

bool debugLogicEnabled = true;

class WomboComboLogic extends ChangeNotifier {
  List<String> _players = [];
  
  List<String> get players => _players;
  
  set players(List<String> newPlayers) {
    _players = List.from(newPlayers);
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Setting players: ${newPlayers.length} players');
    }
    
    if (playerPositions.length < _players.length) {
      final newPositions = List<int>.from(playerPositions);
      for (int i = playerPositions.length; i < _players.length; i++) {
        newPositions.add(1);
      }
      playerPositions = newPositions;
    } else if (playerPositions.length > _players.length) {
      playerPositions = playerPositions.sublist(0, _players.length);
    }
    
    if (currentPlayerIndex >= _players.length && _players.isNotEmpty) {
      currentPlayerIndex = 0;
    }
    notifyListeners();
  }

  int currentPlayerIndex = 0;
  List<int> playerPositions = []; 
  int diceValue = 1;
  bool isRolling = false;
  bool showPlayersMenu = false;
  bool showContent = false; // No se usa más
  bool is123Active = false;
  bool isDiceButtonDisabled = false;
  String currentContent = '';
  Timer? timer123Interval;
  int timeLeft123 = 20;
  bool showTimeoutMessageFlag = false;
  bool showVictoryScreen = false; 
  
  // Variables para el overlay del dado
  bool showDiceOverlay = false;
  String diceOverlayTitle = '';
  String diceOverlayContent = '';
  String diceOverlayExplanation = '';
  int diceOverlayPlayerPosition = 0; // NUEVO: posición del jugador
  String diceOverlayPlayerName = ''; // NUEVO: nombre del jugador

  Set<int> usedRules = {};
  Set<int> usedChallenges123 = {};
  Set<int> usedYoNunca = {};
  Set<int> usedFriki = {};
  Set<int> usedQuienMas = {};
  Set<int> used123 = {};
  Set<int> usedVerdad = {};
  Set<int> usedBeber = {};
  Set<int> usedPreferencias = {};

  WomboComboLogic({required List<String> players}) {
    this.players = players;
    playerPositions = List<int>.filled(_players.length, 1);
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Initialized with ${_players.length} players: $_players');
    }
  }

  @override
  void dispose() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Disposing WomboComboLogic');
    }
    timer123Interval?.cancel();
    super.dispose();
  }

  void updatePlayers(List<String> newPlayers) {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Updating players from ${_players.length} to ${newPlayers.length}');
    }
    players = newPlayers;
  }

  void disableDiceButtonTemporarily() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Disabling dice button temporarily');
    }
    
    isDiceButtonDisabled = true;
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Enabling dice button after delay');
      }
      
      isDiceButtonDisabled = false;
      notifyListeners();
    });
  }

  String getRandomContent(List<String> contentArray, Set<int> usedSet) {
    if (contentArray.isEmpty) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Empty content array provided');
      }
      return "¡Sigue jugando!";
    }
    
    // Buscar contenido que pueda ser procesado con los jugadores disponibles
    List<int> availableIndices = [];
    
    for (int i = 0; i < contentArray.length; i++) {
      if (!usedSet.contains(i) && _canProcessText(contentArray[i])) {
        availableIndices.add(i);
      }
    }
    
    if (availableIndices.isEmpty) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] All content used or not processable, resetting set');
      }
      usedSet.clear();
      availableIndices = List.generate(contentArray.length, (index) => index)
          .where((index) => _canProcessText(contentArray[index]))
          .toList();
    }
    
    // Si aún no hay contenido procesable, usar cualquier contenido
    if (availableIndices.isEmpty) {
      availableIndices = List.generate(contentArray.length, (index) => index);
    }
    
    final randomIndex = availableIndices[Random().nextInt(availableIndices.length)];
    usedSet.add(randomIndex);
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Selected content at index $randomIndex from ${contentArray.length} options');
    }
    
    return contentArray[randomIndex];
  }

  /// Verifica si una frase puede ser procesada con los jugadores disponibles
  bool _canProcessText(String text) {
    if (!text.contains('----')) return true;
    
    // Contar cuántos "----" hay en el texto
    final placeholderCount = (text.split('----').length - 1);
    
    // Obtener jugadores disponibles (excluyendo al jugador actual)
    final availablePlayers = _getAvailablePlayers();
    
    // Verificar si hay suficientes jugadores disponibles
    return availablePlayers.length >= placeholderCount;
  }

  String processText(String text, {bool excludeCurrent = true}) {
    if (!text.contains('----')) {
      return text;
    }
    
    List<String> availablePlayers = excludeCurrent ? _getAvailablePlayers() : List.from(_players);
    
    final placeholderCount = (text.split('----').length - 1);
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Processing text with $placeholderCount placeholders, ${availablePlayers.length} available players');
    }
    
    // Si no hay suficientes jugadores disponibles (y estamos excluyendo al actual)
    if (excludeCurrent && availablePlayers.length < placeholderCount) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Not enough players excluding current, using all players');
      }
      availablePlayers = List.from(_players);
    }
    
    availablePlayers.shuffle();
    
    String result = text;
    for (int i = 0; i < placeholderCount; i++) {
      if (i < availablePlayers.length) {
        // Usar un jugador diferente para cada placeholder si es posible
        result = result.replaceFirst('----', availablePlayers[i]);
      } else {
        // Si no hay suficientes jugadores únicos, repetir o usar marcador genérico
        result = result.replaceFirst('----', 'Otro jugador');
      }
    }
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Processed text: "$result"');
    }
    
    return result;
  }

  /// Obtiene la lista de jugadores disponibles para sustitución (excluyendo al actual)
  List<String> _getAvailablePlayers() {
    if (_players.isEmpty) return [];
    
    List<String> availablePlayers = [];
    
    // Excluir siempre al jugador actual
    for (int i = 0; i < _players.length; i++) {
      if (i != currentPlayerIndex) {
        availablePlayers.add(_players[i]);
      }
    }
    
    return availablePlayers;
  }

  void rollDice() {
    if (isRolling || is123Active || isDiceButtonDisabled || _players.isEmpty || showVictoryScreen) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Dice roll BLOCKED - '
                   'isRolling: $isRolling, '
                   'is123Active: $is123Active, '
                   'isDiceButtonDisabled: $isDiceButtonDisabled, '
                   'players: ${_players.length}, '
                   'showVictory: $showVictoryScreen');
      }
      return;
    }
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Starting dice roll for player: ${_players[currentPlayerIndex]} (index: $currentPlayerIndex)');
    }
    
    showTimeoutMessageFlag = false;
    notifyListeners();
    
    disableDiceButtonTemporarily();
    
    isRolling = true;
    notifyListeners();

    int counter = 0;
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Starting dice animation');
    }
    
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      diceValue = (Random().nextInt(6)) + 1;
      notifyListeners();
      counter++;
      
      if (counter >= 10) {
        timer.cancel();
        final finalValue = (Random().nextInt(6)) + 1;
        diceValue = finalValue;
        isRolling = false;
        
        if (debugLogicEnabled) {
          debugPrint('[LOGIC] Dice roll finished with value: $finalValue');
        }
        
        notifyListeners();

        movePlayer(finalValue);
      }
    });
  }

  void movePlayer(int steps) {
    if (_players.isEmpty) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Cannot move player: no players');
      }
      return;
    }
    
    final currentPosition = playerPositions[currentPlayerIndex];
    int newPosition = currentPosition + steps;
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Moving player ${_players[currentPlayerIndex]} from $currentPosition to $newPosition (+$steps)');
    }
    
    if (newPosition > 80) {
      newPosition = 80 - (newPosition - 80);
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Player bounced back to $newPosition');
      }
    }
    
    playerPositions[currentPlayerIndex] = newPosition;
    notifyListeners();
    
    if (newPosition == 80) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] VICTORY! Player ${_players[currentPlayerIndex]} reached position 80!');
      }
      
      Future.delayed(const Duration(milliseconds: 500), () {
        showVictoryScreen = true;
        notifyListeners();
      });
      return;
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      activateCell(newPosition);
    });
  }

  void activateCell(int position) {
    if (_players.isEmpty) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Cannot activate cell: no players');
      }
      return;
    }
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Activating cell at position $position for player ${_players[currentPlayerIndex]}');
    }
    
    final cell = boardConfig.firstWhere(
      (c) => c['number'] == position,
      orElse: () => {'type': 'default', 'content': '🎲'},
    );

    String content;
    final cellType = cell['type'] ?? 'default';
    final currentPlayer = _players[currentPlayerIndex];
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Cell type: $cellType');
    }
    
    switch (cellType) {
      case 'rule':
        content = getRandomContent(GameData.rules, usedRules);
        showDiceOverlayContent(
          title: 'Regla',
          content: content,
          explanation: 'A seguir hasta nuevo aviso',
          playerName: currentPlayer
        );
        break;
      case 'challenge':
        content = getRandomContent(GameData.retos, usedChallenges123);
        showDiceOverlayContent(
          title: 'Reto',
          content: content,
          explanation: '¡A cumplirlo!',
          playerName: currentPlayer
        );
        break;
      case 'yo-nunca':
        content = getRandomContent(GameData.yoNuncaFrases, usedYoNunca);
        showDiceOverlayContent(
          title: 'Yo Nunca',
          content: content,
          explanation: 'Quién lo ha hecho bebe',
          playerName: currentPlayer
        );
        break;
      case 'friki':
        content = getRandomContent(GameData.frikiQuestions, usedFriki);
        showDiceOverlayContent(
          title: 'Pregunta Friki',
          content: content,
          explanation: 'Todos responden',
          playerName: currentPlayer
        );
        break;
      case 'quien-mas':
        content = getRandomContent(GameData.quienMasProbableFrases, usedQuienMas);
        final processedContent = processText(content);
        showDiceOverlayContent(
          title: '¿Quién es más probable?',
          content: processedContent,
          explanation: 'El elegido bebe',
          playerName: currentPlayer
        );
        break;
      case '123':
        content = getRandomContent(GameData.challenges123, used123);
        show123Timer(processText(content));
        break;
      case 'verdad':
        content = getRandomContent(GameData.verdades, usedVerdad);
        showDiceOverlayContent(
          title: 'Verdad',
          content: content,
          explanation: '¡Responde con sinceridad!',
          playerName: currentPlayer
        );
        break;
      case 'drink':
        content = "¡Todos se acaban su copa!";
        showDiceOverlayContent(
          title: '¡Bebida!',
          content: content,
          explanation: 'Salud 🍻',
          playerName: currentPlayer
        );
        break;
      case 'beber':
        content = getRandomContent(GameData.beber, usedBeber);
        final processedContent = processText(content);
        showDiceOverlayContent(
          title: '¡A beber!',
          content: processedContent,
          explanation: 'Que aproveche',
          playerName: currentPlayer
        );
        break;
      case 'preferencias':
        content = getRandomContent(GameData.preferencias, usedPreferencias);
        showDiceOverlayContent(
          title: '¿Qué prefieres?',
          content: content,
          explanation: 'Todos responden, la minoría bebe',
          playerName: currentPlayer
        );
        break;
      case 'start':
        content = "Casilla de inicio. ¡Suerte!";
        showDiceOverlayContent(
          title: 'Inicio',
          content: content,
          explanation: 'Empieza el juego',
          playerName: currentPlayer
        );
        break;
      case 'end':
        content = "¡Has llegado a la meta! ¡Felicidades!";
        showDiceOverlayContent(
          title: '¡Meta!',
          content: content,
          explanation: 'Ganaste el juego',
          playerName: currentPlayer
        );
        break;
      default:
        content = "¡Sigue jugando!";
        showDiceOverlayContent(
          title: 'Casilla normal',
          content: content,
          explanation: 'Continúa tu turno',
          playerName: currentPlayer
        );
    }
  }

  void showDiceOverlayContent({
    required String title,
    required String content,
    required String explanation,
    required String playerName
  }) {
    // Obtener la posición actual del jugador
    final position = playerPositions[currentPlayerIndex];
    
    if (debugLogicEnabled) {
      final shortContent = content.length > 50 ? content.substring(0, 50) + '...' : content;
      debugPrint('[LOGIC] Showing dice overlay: "$title" - "$shortContent" - "$explanation" for $playerName at position $position');
    }
    
    Future.delayed(const Duration(milliseconds: 50), () {
      diceOverlayTitle = title;
      diceOverlayContent = content;
      diceOverlayExplanation = explanation;
      
      // Guardar la posición y nombre del jugador para mostrarlos en el overlay
      diceOverlayPlayerPosition = position;
      diceOverlayPlayerName = playerName;
      
      showDiceOverlay = true;
      notifyListeners();
    });
  }

  void hideDiceOverlay() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Hiding dice overlay');
    }
    
    showDiceOverlay = false;
    
    // Avanzar al siguiente jugador automáticamente después de cerrar el overlay
    Future.delayed(const Duration(milliseconds: 50), () {
      nextPlayer();
    });
  }

  void show123Timer(String challengeText) {
    if (debugLogicEnabled) {
      final shortChallenge = challengeText.length > 50 ? challengeText.substring(0, 50) + '...' : challengeText;
      debugPrint('[LOGIC] Starting 123 timer with challenge: "$shortChallenge"');
    }
    
    showDiceOverlay = false;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 50), () {
      is123Active = true;
      timeLeft123 = 20;
      currentContent = challengeText;
      showTimeoutMessageFlag = false;
      
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] 123 Timer started: $timeLeft123 seconds');
      }
      
      notifyListeners();

      start123Timer();
    });
  }

  void start123Timer() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Starting 123 countdown timer');
    }
    
    timer123Interval?.cancel();
    
    timer123Interval = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft123--;
      
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] 123 Timer: $timeLeft123 seconds remaining');
      }
      
      notifyListeners();
      
      if (timeLeft123 <= 0) {
        timer.cancel();
        
        if (debugLogicEnabled) {
          debugPrint('[LOGIC] 123 Timer expired');
        }
        
        showTimeoutMessageFunc();
      }
    });
  }

  void showTimeoutMessageFunc() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Showing timeout message');
    }
    
    is123Active = false;
    showTimeoutMessageFlag = true;
    notifyListeners();
  }

  void hide123Timer() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Hiding 123 timer');
    }
    
    timer123Interval?.cancel();
    is123Active = false;
    showTimeoutMessageFlag = false;
    notifyListeners();
  }

  void skipTimer() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Skipping 123 timer');
    }
    
    if (is123Active) {
      hide123Timer();
    }
  }

  void nextPlayer() {
    if (_players.isEmpty) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] No players to switch to');
      }
      return;
    }
    
    final oldPlayer = _players.isNotEmpty ? _players[currentPlayerIndex] : "none";
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Switching from player $oldPlayer (index: $currentPlayerIndex)');
    }
    
    showTimeoutMessageFlag = false;
    
    currentPlayerIndex = (currentPlayerIndex + 1) % _players.length;
    
    final newPlayer = _players.isNotEmpty ? _players[currentPlayerIndex] : "none";
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Now it\'s player $newPlayer\'s turn (index: $currentPlayerIndex)');
    }
    
    notifyListeners();
    
    isDiceButtonDisabled = false;
    notifyListeners();
  }

  void restartGame() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Restarting game');
    }
    
    playerPositions = List.filled(_players.length, 1);
    currentPlayerIndex = 0;
    showDiceOverlay = false;
    is123Active = false;
    isDiceButtonDisabled = false;
    showTimeoutMessageFlag = false;
    showVictoryScreen = false; 
    
    usedRules.clear();
    usedChallenges123.clear();
    usedYoNunca.clear();
    usedFriki.clear();
    usedQuienMas.clear();
    used123.clear();
    usedVerdad.clear();
    usedBeber.clear();
    usedPreferencias.clear();
    
    timer123Interval?.cancel();
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Game restarted, first player: ${_players.isNotEmpty ? _players[0] : "none"}');
    }
    
    notifyListeners();
  }

  // Método para reiniciar desde la pantalla de victoria
  void restartGameFromVictory() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Restarting game from victory screen');
    }
    
    playerPositions = List.filled(_players.length, 1);
    currentPlayerIndex = 0;
    showVictoryScreen = false;
    showDiceOverlay = false;
    is123Active = false;
    isDiceButtonDisabled = false;
    showTimeoutMessageFlag = false;
    
    usedRules.clear();
    usedChallenges123.clear();
    usedYoNunca.clear();
    usedFriki.clear();
    usedQuienMas.clear();
    used123.clear();
    usedVerdad.clear();
    usedBeber.clear();
    usedPreferencias.clear();
    
    timer123Interval?.cancel();
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Game restarted from victory');
    }
    
    notifyListeners();
  }

  Color getPlayerColor(int index) {
    if (index < 0 || index >= _players.length) {
      if (debugLogicEnabled) {
        debugPrint('[LOGIC] Invalid player index: $index, returning grey');
      }
      return Colors.grey; 
    }
    
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFFFF9FF3),
      const Color(0xFF54A0FF),
      const Color(0xFFFF7979),
      const Color(0xFFBADc58),
      const Color(0xFFF9CA24),
    ];
    return colors[index % colors.length];
  }

  bool get hasPlayerWon => _players.isNotEmpty && playerPositions[currentPlayerIndex] == 80;
  String get currentPlayerName => _players.isNotEmpty ? _players[currentPlayerIndex] : "Sin jugadores";
  int get currentPlayerPosition => _players.isNotEmpty ? playerPositions[currentPlayerIndex] : 0;
  
  bool get showTimeoutMessage => showTimeoutMessageFlag;
  
  // Métodos para debug
  void printStatus() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] === STATUS ===');
      debugPrint('[LOGIC] Players: $_players');
      debugPrint('[LOGIC] Positions: $playerPositions');
      debugPrint('[LOGIC] Current player: $currentPlayerIndex (${currentPlayerName})');
      debugPrint('[LOGIC] Dice: $diceValue, Rolling: $isRolling');
      debugPrint('[LOGIC] 123 Active: $is123Active, Time left: $timeLeft123');
      debugPrint('[LOGIC] Dice button disabled: $isDiceButtonDisabled');
      debugPrint('[LOGIC] Show dice overlay: $showDiceOverlay');
      debugPrint('[LOGIC] Show victory: $showVictoryScreen');
      debugPrint('[LOGIC] ===============');
    }
  }
  
  void togglePlayersMenu() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] Toggling players menu from ${showPlayersMenu} to ${!showPlayersMenu}');
    }
    
    showPlayersMenu = !showPlayersMenu;
    notifyListeners();
  }
  
  void debugTogglePlayersMenu() {
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] debugTogglePlayersMenu called');
      debugPrint('[LOGIC] Current showPlayersMenu: $showPlayersMenu');
    }
    
    showPlayersMenu = !showPlayersMenu;
    
    if (debugLogicEnabled) {
      debugPrint('[LOGIC] New showPlayersMenu: $showPlayersMenu');
    }
    
    notifyListeners();
  }
}