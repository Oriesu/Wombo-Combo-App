import 'package:flutter/foundation.dart';

class PlayersProvider with ChangeNotifier {
  List<String> _players = [];

  List<String> get players => List.from(_players); // Devuelve copia para evitar modificaciones externas

  void addPlayer(String name) {
    if (!_players.contains(name)) {
      _players.add(name);
      notifyListeners();
    }
  }

  void removePlayer(String name) {
    _players.remove(name);
    notifyListeners();
  }

  void removePlayerByIndex(int index) {
    if (index >= 0 && index < _players.length) {
      _players.removeAt(index);
      notifyListeners();
    }
  }

  void clearPlayers() {
    _players.clear();
    notifyListeners();
  }

  bool get hasEnoughPlayers => _players.length >= 2;
}