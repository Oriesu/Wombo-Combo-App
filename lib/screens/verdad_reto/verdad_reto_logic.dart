import '../../data/game_data.dart';

class VerdadRetoLogic {
  final Set<int> _usedVerdades = {};
  final Set<int> _usedRetos = {};
  String _currentContent = '';
  bool _showContent = false;
  bool _isVerdad = false;
  int _currentPlayerIndex = 0;

  String get currentContent => _currentContent;
  bool get showContent => _showContent;
  bool get isVerdad => _isVerdad;

  void nextPlayer(List<String> players) {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
  }

  String getCurrentPlayer(List<String> players) {
    return players[_currentPlayerIndex];
  }

  int getCurrentPlayerIndex(List<String> players) {
    return _currentPlayerIndex;
  }

  void showVerdad(List<String> players) {
    // Obtener frases disponibles que puedan ser procesadas con los jugadores actuales
    List<MapEntry<int, String>> availableVerdades = GameData.verdades
        .asMap()
        .entries
        .where((entry) => !_usedVerdades.contains(entry.key))
        .where((entry) => _canProcessText(entry.value, players))
        .toList();

    if (availableVerdades.isEmpty) {
      // Resetear las usadas y buscar de nuevo
      _usedVerdades.clear();
      availableVerdades = GameData.verdades
          .asMap()
          .entries
          .where((entry) => _canProcessText(entry.value, players))
          .toList();
    }

    if (availableVerdades.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableVerdades.length);
      final selectedEntry = availableVerdades[randomIndex];
      
      _usedVerdades.add(selectedEntry.key);
      _currentContent = _processText(selectedEntry.value, players);
      _isVerdad = true;
      _showContent = true;
      
      // Cambiar al siguiente jugador inmediatamente
      nextPlayer(players);
    } else {
      // Si no hay ninguna frase que se pueda procesar
      _currentContent = "No hay suficientes jugadores para esta verdad. ¡Añade más amigos!";
      _isVerdad = true;
      _showContent = true;
    }
  }

  void showReto(List<String> players) {
    // Obtener frases disponibles que puedan ser procesadas con los jugadores actuales
    List<MapEntry<int, String>> availableRetos = GameData.retos
        .asMap()
        .entries
        .where((entry) => !_usedRetos.contains(entry.key))
        .where((entry) => _canProcessText(entry.value, players))
        .toList();

    if (availableRetos.isEmpty) {
      // Resetear las usadas y buscar de nuevo
      _usedRetos.clear();
      availableRetos = GameData.retos
          .asMap()
          .entries
          .where((entry) => _canProcessText(entry.value, players))
          .toList();
    }

    if (availableRetos.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableRetos.length);
      final selectedEntry = availableRetos[randomIndex];
      
      _usedRetos.add(selectedEntry.key);
      _currentContent = _processText(selectedEntry.value, players);
      _isVerdad = false;
      _showContent = true;
      
      // Cambiar al siguiente jugador inmediatamente
      nextPlayer(players);
    } else {
      // Si no hay ninguna frase que se pueda procesar
      _currentContent = "No hay suficientes jugadores para este reto. ¡Añade más amigos!";
      _isVerdad = false;
      _showContent = true;
    }
  }

  /// Verifica si una frase puede ser procesada con los jugadores disponibles
  bool _canProcessText(String text, List<String> players) {
    // Contar cuántos "----" hay en el texto
    final placeholderCount = '----'.allMatches(text).length;
    
    if (placeholderCount == 0) return true;
    
    // Obtener jugadores disponibles (excluyendo al jugador actual)
    List<String> availablePlayers = _getAvailablePlayers(players);
    
    // Verificar si hay suficientes jugadores disponibles
    return availablePlayers.length >= placeholderCount;
  }

  String _processText(String text, List<String> players) {
    // Contar cuántos "----" hay en el texto
    final placeholderCount = '----'.allMatches(text).length;
    
    if (placeholderCount == 0) return text;
    
    // Obtener jugadores disponibles (excluyendo al jugador actual)
    List<String> availablePlayers = _getAvailablePlayers(players);
    
    // Mezclar los jugadores disponibles
    availablePlayers.shuffle();
    
    // Reemplazar cada "----" con un jugador diferente
    String result = text;
    
    for (int i = 0; i < placeholderCount; i++) {
      if (i < availablePlayers.length) {
        // Usar un jugador diferente para cada placeholder si es posible
        result = result.replaceFirst('----', availablePlayers[i]);
      } else {
        // Esto no debería pasar porque _canProcessText ya verificó que hay suficientes
        result = result.replaceFirst('----', 'Otro jugador');
      }
    }
    
    return result;
  }

  /// Obtiene la lista de jugadores disponibles para sustitución (excluyendo al actual)
  List<String> _getAvailablePlayers(List<String> players) {
    if (players.isEmpty) return [];
    
    List<String> availablePlayers = [];
    
    // Excluir siempre al jugador actual
    for (int i = 0; i < players.length; i++) {
      if (i != _currentPlayerIndex) {
        availablePlayers.add(players[i]);
      }
    }
    
    return availablePlayers;
  }

  int _getRandomIndex(int max) {
    return DateTime.now().microsecondsSinceEpoch % max;
  }

  void reset() {
    _usedVerdades.clear();
    _usedRetos.clear();
    _currentContent = '';
    _showContent = false;
    _currentPlayerIndex = 0;
  }
}