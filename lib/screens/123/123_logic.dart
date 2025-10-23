import 'dart:math';
import '../../data/game_data.dart';

class OneTwoThreeLogic {
  final List<String> players;
  int currentPlayerIndex = 0;
  int timeLeft = 10;
  String currentChallenge = '';
  bool _timerRunning = false;
  
  // Callbacks para notificar cambios a la UI
  Function(String)? onChallengeChanged;
  Function(int)? onTimerChanged;
  Function(String)? onPlayerChanged;
  
  OneTwoThreeLogic(this.players) {
    _shufflePlayers();
    _getRandomChallenge();
  }
  
  // Mezclar jugadores (algoritmo Fisher-Yates)
  void _shufflePlayers() {
    final random = Random();
    for (int i = players.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = players[i];
      players[i] = players[j];
      players[j] = temp;
    }
  }
  
  // Obtener desafío aleatorio
  void _getRandomChallenge() {
    final random = Random();
    if (GameData.challenges123.isNotEmpty) {
      currentChallenge = GameData.challenges123[random.nextInt(GameData.challenges123.length)];
      onChallengeChanged?.call(currentChallenge);
    }
  }
  
  // Obtener jugador actual
  String get currentPlayer {
    if (players.isEmpty) return '';
    return players[currentPlayerIndex];
  }
  
  // Iniciar temporizador
  void startTimer() {
    if (_timerRunning) return;
    
    _timerRunning = true;
    timeLeft = 10;
    onTimerChanged?.call(timeLeft);
    
    // Simular el intervalo del JavaScript
    _timerTick();
  }
  
  void _timerTick() {
    if (!_timerRunning) return;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!_timerRunning) return;
      
      timeLeft--;
      onTimerChanged?.call(timeLeft);
      
      if (timeLeft <= 0) {
        _timerRunning = false;
        // Tiempo acabado - el jugador debe beber
      } else {
        _timerTick();
      }
    });
  }
  
  // Detener temporizador
  void stopTimer() {
    _timerRunning = false;
  }
  
  // Siguiente jugador
  void nextPlayer() {
    stopTimer();
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    _getRandomChallenge();
    
    onPlayerChanged?.call(currentPlayer);
    startTimer();
  }
  
  // Reiniciar juego
  void reset() {
    stopTimer();
    currentPlayerIndex = 0;
    _shufflePlayers();
    _getRandomChallenge();
    
    onPlayerChanged?.call(currentPlayer);
    onTimerChanged?.call(10);
  }
  
  void dispose() {
    stopTimer();
  }
}