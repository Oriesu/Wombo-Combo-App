import 'dart:async'; // ¡IMPORTANTE! Agregar esto al inicio
import 'dart:math';
import '../../data/game_data.dart';

class OneTwoThreeLogic {
  final List<String> players;
  int currentPlayerIndex = 0;
  int timeLeft = 10;
  String currentChallenge = '';
  bool _timerRunning = false;
  Timer? _timer; // ¡AGREGAR ESTO! Para controlar el timer
  
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
  
  // Iniciar temporizador (CORREGIDO)
  void startTimer() {
    // 1. Detener timer anterior si existe
    _timer?.cancel();
    _timerRunning = false;
    
    // 2. Resetear tiempo
    timeLeft = 10;
    onTimerChanged?.call(timeLeft);
    
    // 3. Iniciar nuevo timer
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_timerRunning) {
        timer.cancel();
        return;
      }
      
      timeLeft--;
      onTimerChanged?.call(timeLeft);
      
      if (timeLeft <= 0) {
        _timerRunning = false;
        timer.cancel();
        // Tiempo acabado - el jugador debe beber
      }
    });
  }
  
  // Detener temporizador (CORREGIDO)
  void stopTimer() {
    _timerRunning = false;
    _timer?.cancel();
    _timer = null;
  }
  
  // Siguiente jugador (CORREGIDO)
  void nextPlayer() {
    stopTimer(); // Esto ahora cancela el timer correctamente
    
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    _getRandomChallenge();
    
    onPlayerChanged?.call(currentPlayer);
    startTimer(); // Esto iniciará un timer nuevo y fresco
  }
  
  // Reiniciar juego (CORREGIDO)
  void reset() {
    stopTimer(); // Cancelar timer actual
    currentPlayerIndex = 0;
    _shufflePlayers();
    _getRandomChallenge();
    
    onPlayerChanged?.call(currentPlayer);
    onTimerChanged?.call(10);
  }
  
  void dispose() {
    stopTimer(); // Asegurar que el timer se cancele
    _timer?.cancel(); // Cancelar por si acaso
  }
}