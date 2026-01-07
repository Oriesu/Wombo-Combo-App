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
    List<String> availableVerdades = GameData.verdades
        .asMap()
        .entries
        .where((entry) => !_usedVerdades.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (availableVerdades.isEmpty) {
      _usedVerdades.clear();
      availableVerdades = List.from(GameData.verdades);
    }

    if (availableVerdades.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableVerdades.length);
      final verdadIndex = GameData.verdades.indexOf(availableVerdades[randomIndex]);
      
      _usedVerdades.add(verdadIndex);
      _currentContent = _processText(availableVerdades[randomIndex], players);
      _isVerdad = true;
      _showContent = true;
      
      // Cambiar al siguiente jugador inmediatamente
      nextPlayer(players);
    }
  }

  void showReto(List<String> players) {
    List<String> availableRetos = GameData.retos
        .asMap()
        .entries
        .where((entry) => !_usedRetos.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (availableRetos.isEmpty) {
      _usedRetos.clear();
      availableRetos = List.from(GameData.retos);
    }

    if (availableRetos.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableRetos.length);
      final retoIndex = GameData.retos.indexOf(availableRetos[randomIndex]);
      
      _usedRetos.add(retoIndex);
      _currentContent = _processText(availableRetos[randomIndex], players);
      _isVerdad = false;
      _showContent = true;
      
      // Cambiar al siguiente jugador inmediatamente
      nextPlayer(players);
    }
  }

  String _processText(String text, List<String> players) {
    // Contar cuántos "----" hay en el texto
    final placeholderCount = '----'.allMatches(text).length;
    
    if (placeholderCount == 0) return text;
    
    // Obtener jugadores aleatorios (excluyendo al actual)
    List<String> availablePlayers = List.from(players);
    availablePlayers.removeAt(_currentPlayerIndex);
    
    // Si no hay suficientes jugadores, incluir a todos
    if (availablePlayers.length < placeholderCount) {
      availablePlayers = List.from(players);
      // Remover el actual de nuevo si está incluido
      availablePlayers.removeAt(_currentPlayerIndex);
      if (availablePlayers.length < placeholderCount) {
        availablePlayers = List.from(players);
      }
    }
    
    // Mezclar y tomar los necesarios
    availablePlayers.shuffle();
    final selectedPlayers = availablePlayers.take(placeholderCount).toList();
    
    // Reemplazar cada "----" con un jugador
    String result = text;
    for (final player in selectedPlayers) {
      result = result.replaceFirst('----', player);
    }
    
    return result;
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