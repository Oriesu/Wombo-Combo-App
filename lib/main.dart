import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/add_players/add_players_screen.dart';
import 'providers/player_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayersProvider(),
      child: MaterialApp(
        title: 'Juego de Beber',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AddPlayersScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}