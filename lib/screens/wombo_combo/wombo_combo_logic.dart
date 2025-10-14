import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../data/game_data.dart';
import '../../widgets/game_board.dart'; // Importar el tablero
import 'dart:async';    
import 'dart:math';     

class WomboComboLogic extends ChangeNotifier {
  List<String> players;
  
  int currentPlayerIndex = 0;
  List<int> playerPositions = [];
  int diceValue = 1;
  bool isRolling = false;
  bool showPlayersMenu = false;
  bool showContent = false;
  bool is123Active = false;
  bool isDiceButtonDisabled = false;
  String currentContent = '';
  Timer? timer123Interval;
  int timeLeft123 = 20;
  bool showTimeoutMessageFlag = false;

  // Conjuntos para controlar contenido usado
  Set<int> usedRules = {};
  Set<int> usedChallenges123 = {};
  Set<int> usedYoNunca = {};
  Set<int> usedFriki = {};
  Set<int> usedQuienMas = {};
  Set<int> used123 = {};
  Set<int> usedVerdad = {};

  WomboComboLogic({required this.players}) {
    // Inicializar con lista mutable
    playerPositions = List<int>.filled(players.length, 1);
  }

  @override
  void dispose() {
    timer123Interval?.cancel();
    super.dispose();
  }

  // Actualizar jugadores cuando cambian desde el provider
  void updatePlayers(List<String> newPlayers) {
    players = List.from(newPlayers);
    
    // Ajustar playerPositions si es necesario
    if (playerPositions.length < players.length) {
      // Agregar posiciones para nuevos jugadores
      for (int i = playerPositions.length; i < players.length; i++) {
        playerPositions.add(1);
      }
    } else if (playerPositions.length > players.length) {
      // Remover posiciones de jugadores eliminados
      playerPositions = playerPositions.sublist(0, players.length);
    }
    
    // Ajustar currentPlayerIndex si es necesario
    if (currentPlayerIndex >= players.length) {
      currentPlayerIndex = 0;
    }
    
    notifyListeners();
  }

  void disableDiceButtonTemporarily() {
    isDiceButtonDisabled = true;
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 2), () {
      isDiceButtonDisabled = false;
      notifyListeners();
    });
  }

  String getRandomContent(List<String> contentArray, Set<int> usedSet) {
    List<int> availableIndices = [];
    
    for (int i = 0; i < contentArray.length; i++) {
      if (!usedSet.contains(i)) {
        availableIndices.add(i);
      }
    }
    
    if (availableIndices.isEmpty) {
      usedSet.clear();
      availableIndices = List.generate(contentArray.length, (index) => index);
    }
    
    final randomIndex = availableIndices[Random().nextInt(availableIndices.length)];
    usedSet.add(randomIndex);
    
    return contentArray[randomIndex];
  }

  String processText(String text, {bool excludeCurrent = true}) {
    if (!text.contains('----')) return text;
    
    List<String> availablePlayers = [];
    for (int i = 0; i < players.length; i++) {
      if (!excludeCurrent || i != currentPlayerIndex) {
        availablePlayers.add(players[i]);
      }
    }
    
    final placeholderCount = (text.split('----').length - 1);
    if (availablePlayers.length < placeholderCount) {
      availablePlayers = List.from(players);
    }
    
    availablePlayers.shuffle();
    
    String result = text;
    for (String player in availablePlayers) {
      result = result.replaceFirst('----', player);
      if (!result.contains('----')) break;
    }
    
    return result;
  }

  void rollDice() {
    if (isRolling || is123Active || isDiceButtonDisabled) return;
    
    showContent = false;
    showTimeoutMessageFlag = false;
    notifyListeners();
    
    disableDiceButtonTemporarily();
    
    isRolling = true;
    notifyListeners();

    int counter = 0;
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      diceValue = (Random().nextInt(6)) + 1;
      notifyListeners();
      counter++;
      
      if (counter >= 10) {
        timer.cancel();
        final finalValue = (Random().nextInt(6)) + 1;
        diceValue = finalValue;
        isRolling = false;
        notifyListeners();

        movePlayer(finalValue);
      }
    });
  }

  void movePlayer(int steps) {
    final currentPosition = playerPositions[currentPlayerIndex];
    int newPosition = currentPosition + steps;
    
    if (newPosition > 80) {
      newPosition = 80 - (newPosition - 80);
    }
    
    playerPositions[currentPlayerIndex] = newPosition;
    notifyListeners();
    
    if (newPosition == 80) {
      return;
    }
    
    Future.delayed(const Duration(milliseconds: 510), () {
      activateCell(newPosition);
    });
  }

  void activateCell(int position) {
    // Usar boardConfig importado desde game_board.dart
    final cell = boardConfig.firstWhere(
      (c) => c['number'] == position,
      orElse: () => {'type': 'default', 'content': '🎲'},
    );

    String content;
    
    switch (cell['type']) {
      case 'rule':
        content = getRandomContent(GameData.rules, usedRules);
        showRegularContent(content);
        break;
      case 'challenge':
        content = getRandomContent(GameData.retos, usedChallenges123);
        showRegularContent(content);
        break;
      case 'yo-nunca':
        content = getRandomContent(GameData.yoNuncaFrases, usedYoNunca);
        showRegularContent(content);
        break;
      case 'friki':
        content = getRandomContent(GameData.frikiQuestions, usedFriki);
        showRegularContent(content);
        break;
      case 'quien-mas':
        content = getRandomContent(GameData.quienMasProbableFrases, usedQuienMas);
        showRegularContent(content);
        break;
      case '123':
        content = getRandomContent(GameData.challenges123, used123);
        show123Timer(processText(content));
        break;
      case 'verdad':
        content = getRandomContent(GameData.verdades, usedVerdad);
        showRegularContent(content);
        break;
      case 'drink':
        content = "¡Todos se acaban su copa!";
        showRegularContent(content);
        break;
      case 'start':
        content = "Casilla de inicio. ¡Suerte!";
        showRegularContent(content);
        break;
      case 'end':
        content = "¡Has llegado a la meta! ¡Felicidades!";
        showRegularContent(content);
        break;
      default:
        content = "¡Sigue jugando!";
        showRegularContent(content);
    }
  }

  void showRegularContent(String content) {
    final processedContent = processText(content);
    currentContent = processedContent;
    showContent = true;
    notifyListeners();
  }

  void show123Timer(String challengeText) {
    is123Active = true;
    timeLeft123 = 20;
    currentContent = challengeText;
    showContent = true;
    showTimeoutMessageFlag = false;
    notifyListeners();

    start123Timer();
  }

  void start123Timer() {
    timer123Interval?.cancel();
    
    timer123Interval = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft123--;
      notifyListeners();
      
      if (timeLeft123 <= 0) {
        timer.cancel();
        showTimeoutMessageFunc();
      }
    });
  }

  void showTimeoutMessageFunc() {
    is123Active = false;
    showTimeoutMessageFlag = true;
    currentContent = "¡Se acabó el tiempo, bebe por cada una que no dijiste!";
    notifyListeners();
  }

  void hide123Timer() {
    timer123Interval?.cancel();
    is123Active = false;
    showTimeoutMessageFlag = false;
    notifyListeners();
  }

  void skipTimer() {
    if (is123Active) {
      hide123Timer();
    }
  }

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    showTimeoutMessageFlag = false;
    notifyListeners();
  }

  void restartGame() {
    playerPositions = List.filled(players.length, 1);
    currentPlayerIndex = 0;
    showContent = false;
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
    
    timer123Interval?.cancel();
    notifyListeners();
  }

  Color getPlayerColor(int index) {
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

  bool get hasPlayerWon => playerPositions[currentPlayerIndex] == 80;
  String get currentPlayerName => players[currentPlayerIndex];
  int get currentPlayerPosition => playerPositions[currentPlayerIndex];
  
  bool get showTimeoutMessage => showTimeoutMessageFlag;
}