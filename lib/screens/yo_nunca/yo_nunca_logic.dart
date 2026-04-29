import '../../data/game_data.dart';

class YoNuncaLogic {
  final Set<int> _usedFrases = {};
  String _currentFrase = '';
  bool _showContent = false;

  String get currentFrase => _currentFrase;
  bool get showContent => _showContent;

  void generateFrase() {
    List<String> availableFrases = GameData.yoNuncaFrases
        .asMap()
        .entries
        .where((entry) => !_usedFrases.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (availableFrases.isEmpty) {
      _usedFrases.clear();
      availableFrases = List.from(GameData.yoNuncaFrases);
    }

    if (availableFrases.isNotEmpty) {
      final randomIndex = _getRandomIndex(availableFrases.length);
      final fraseIndex = GameData.yoNuncaFrases.indexOf(availableFrases[randomIndex]);
      
      _usedFrases.add(fraseIndex);
      _currentFrase = availableFrases[randomIndex];
      _showContent = true;
    }
  }

  int _getRandomIndex(int max) {
    return (DateTime.now().microsecondsSinceEpoch % max);
  }

  void reset() {
    _usedFrases.clear();
    _currentFrase = '';
    _showContent = false;
  }
}