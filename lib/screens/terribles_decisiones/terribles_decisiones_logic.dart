import '../../data/game_data.dart';

class TerriblesDecisionesLogic {
  final Set<int> _usedPreferencias = {};
  String _currentPreferencia = '';
  bool _showContent = false;

  String get currentPreferencia => _currentPreferencia;
  bool get showContent => _showContent;

  void generatePreferencia() {
    List<String> availablePreferencias = GameData.preferencias
        .asMap()
        .entries
        .where((entry) => !_usedPreferencias.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (availablePreferencias.isEmpty) {
      _usedPreferencias.clear();
      availablePreferencias = List.from(GameData.preferencias);
    }

    if (availablePreferencias.isNotEmpty) {
      final randomIndex = _getRandomIndex(availablePreferencias.length);
      final preferenciaIndex = GameData.preferencias.indexOf(availablePreferencias[randomIndex]);
      
      _usedPreferencias.add(preferenciaIndex);
      _currentPreferencia = availablePreferencias[randomIndex];
      _showContent = true;
    }
  }

  int _getRandomIndex(int max) {
    return (DateTime.now().microsecondsSinceEpoch % max);
  }

  void reset() {
    _usedPreferencias.clear();
    _currentPreferencia = '';
    _showContent = false;
  }
}