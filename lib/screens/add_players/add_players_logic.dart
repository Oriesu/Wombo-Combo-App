import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class AddPlayersLogic {
  final TextEditingController playerNameController = TextEditingController();

  void addPlayer(PlayersProvider playersProvider, BuildContext context) {
    final name = playerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre')),
      );
      return;
    }
    
    playersProvider.addPlayer(name);
    playerNameController.clear();
  }

  void removePlayer(PlayersProvider playersProvider, String name) {
    playersProvider.removePlayer(name);
  }

  bool canStartGame(String gameType, PlayersProvider playersProvider) {
    if (!playersProvider.hasEnoughPlayers && 
        gameType != 'yo-nunca' && 
        gameType != 'quien-mas-probable' && 
        gameType != 'caballos' && 
        gameType != 'terribles-decisiones') {
      return false;
    }
    return true;
  }

  void showNotEnoughPlayersMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se necesitan al menos 2 jugadores para este modo')),
    );
  }

  void dispose() {
    playerNameController.dispose();
  }
}