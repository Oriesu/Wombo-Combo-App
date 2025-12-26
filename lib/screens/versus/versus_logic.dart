import '../../data/game_data.dart';

class VersusLogic {
  final Set<int> _usedVersus = {};
  String _currentContent = '';
  bool _showContent = false;
  List<String> _teamBlue = [];
  List<String> _teamRed = [];
  int _blueScore = 0;
  int _redScore = 0;

  String get currentContent => _currentContent;
  bool get showContent => _showContent;
  List<String> get teamBlue => _teamBlue;
  List<String> get teamRed => _teamRed;
  int get blueScore => _blueScore;
  int get redScore => _redScore;

  void initializeTeams(List<String> players) {
    if (players.length < 4) {
      throw Exception('Se necesitan al menos 4 jugadores para el modo Versus');
    }

    // Mezclar jugadores
    final shuffledPlayers = List<String>.from(players)..shuffle();
    
    _teamBlue = [];
    _teamRed = [];
    
    // Distribuir equitativamente
    for (int i = 0; i < shuffledPlayers.length; i++) {
      if (i % 2 == 0) {
        _teamBlue.add(shuffledPlayers[i]);
      } else {
        _teamRed.add(shuffledPlayers[i]);
      }
    }
    
    // Ajustar si hay diferencia de más de 1
    if ((_teamBlue.length - _teamRed.length).abs() > 1) {
      if (_teamBlue.length > _teamRed.length) {
        final movedPlayer = _teamBlue.removeLast();
        _teamRed.add(movedPlayer);
      } else {
        final movedPlayer = _teamRed.removeLast();
        _teamBlue.add(movedPlayer);
      }
    }
    
    _blueScore = 0;
    _redScore = 0;
  }

  void showNextChallenge() {
    List<String> availableVersus = GameData.versus
        .asMap()
        .entries
        .where((entry) => !_usedVersus.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (availableVersus.isEmpty) {
      _usedVersus.clear();
      availableVersus = List.from(GameData.versus);
    }

    if (availableVersus.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableVersus.length);
      final versusIndex = GameData.versus.indexOf(availableVersus[randomIndex]);
      
      _usedVersus.add(versusIndex);
      _currentContent = _processText(availableVersus[randomIndex]);
      _showContent = true;
    }
  }

  void addPointToBlue() {
    _blueScore++;
  }

  void addPointToRed() {
    _redScore++;
  }

  String _processText(String text) {
    // Contar cuántos "----" hay en el texto
    final placeholderCount = '----'.allMatches(text).length;
    
    if (placeholderCount == 0) return text;
    
    // Combinar todos los jugadores para la selección
    final allPlayers = [..._teamBlue, ..._teamRed];
    
    // Mezclar y tomar los necesarios
    final shuffledPlayers = List<String>.from(allPlayers)..shuffle();
    final selectedPlayers = shuffledPlayers.take(placeholderCount).toList();
    
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
    _usedVersus.clear();
    _currentContent = '';
    _showContent = false;
    _teamBlue.clear();
    _teamRed.clear();
    _blueScore = 0;
    _redScore = 0;
  }
}