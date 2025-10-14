import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../yo_nunca/yo_nunca_screen.dart';
import '../terribles_decisiones/terribles_decisiones_screen.dart';  
import '../wombo_combo/wombo_combo_screen.dart';
import '../quien_mas_probable/quien_mas_probable_screen.dart';
import '../../providers/player_provider.dart';
import '../../widgets/player_tag.dart';

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({Key? key}) : super(key: key);

  @override
  _AddPlayersScreenState createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController playerNameController = TextEditingController();

  @override
  void dispose() {
    playerNameController.dispose();
    super.dispose();
  }

  bool canStartGame(String gameType, PlayersProvider playersProvider) {
    final players = playersProvider.players;
    
    switch(gameType) {
      case 'yo-nunca':
      case 'wombo-combo':
      case 'terribles-decisiones':
      case 'quien-mas-probable':
      case 'caballos':
        return players.length >= 2;
      case 'versus':
        return players.length >= 4;
      case 'verdad-reto':
      case '123':
      case 'ruleta':
        return players.length >= 2;
      default:
        return false;
    }
  }

  void showNotEnoughPlayersMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se necesitan al menos 2 jugadores para este juego'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addPlayer(PlayersProvider playersProvider, BuildContext context) {
    final name = playerNameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre')),
      );
      return;
    }
    
    if (playersProvider.players.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nombre ya existe')),
      );
      return;
    }
    
    if (name.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede tener más de 15 caracteres')),
      );
      return;
    }
    
    playersProvider.addPlayer(name);
    playerNameController.clear();
    setState(() {});
  }

  void _removePlayer(String player) {
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    playersProvider.removePlayer(player);
    setState(() {});
  }

  void startGame(String gameType, PlayersProvider playersProvider) {
    if (!canStartGame(gameType, playersProvider)) {
      showNotEnoughPlayersMessage(context);
      return;
    }

    final players = playersProvider.players;

    switch(gameType) {
      case 'yo-nunca':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YoNuncaScreen(players: players),
          ),
        );
        break;
      case 'wombo-combo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WomboComboScreen(players: players),
          ),
        );
        break;
      case 'terribles-decisiones':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TerriblesDecisionesScreen(players: players),
          ),
        );
        break;
      case 'quien-mas-probable':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuienMasProbableScreen(players: players),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modo de juego no disponible aún')),
        );
    }
  }

  Widget _buildGameModeCard({
    required String icon,
    required String name,
    required bool enabled,
    required String gameType,
    required PlayersProvider playersProvider,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: enabled ? () => startGame(gameType, playersProvider) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(enabled ? 0.2 : 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModesGrid(PlayersProvider playersProvider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Primera fila
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🙅‍♂️',
                  name: 'Yo Nunca',
                  enabled: true,
                  gameType: 'yo-nunca',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🤔',
                  name: '¿Quién es más probable?',
                  enabled: true,
                  gameType: 'quien-mas-probable',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Segunda fila
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🗳️',
                  name: 'Terribles decisiones',
                  enabled: true,
                  gameType: 'terribles-decisiones',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🐎',
                  name: 'Carrera de Caballos',
                  enabled: true,
                  gameType: 'caballos',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Tercera fila
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '⚔️',
                  name: 'Versus (4 jugadores)',
                  enabled: playersProvider.players.length >= 4,
                  gameType: 'versus',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '❓',
                  name: 'Verdad o Reto',
                  enabled: playersProvider.players.length >= 2,
                  gameType: 'verdad-reto',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Cuarta fila
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  icon: '🔢',
                  name: '1, 2, 3',
                  enabled: playersProvider.players.length >= 2,
                  gameType: '123',
                  playersProvider: playersProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  icon: '🎰',
                  name: 'Ruleta de tragos',
                  enabled: playersProvider.players.length >= 2,
                  gameType: 'ruleta',
                  playersProvider: playersProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Quinta fila (Wombo Combo - más ancho)
          _buildGameModeCard(
            icon: '🌀',
            name: 'Wombo Combo',
            enabled: playersProvider.players.length >= 2,
            gameType: 'wombo-combo',
            playersProvider: playersProvider,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0033),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0033), Color(0xFF330033)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Agrega Jugadores',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Usar Builder para obtener el Provider de forma segura
                  Builder(
                    builder: (context) {
                      final playersProvider = Provider.of<PlayersProvider>(context, listen: true);
                      final players = playersProvider.players;
                      
                      return Expanded(
                        child: Column(
                          children: [
                            // Input para agregar jugador
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: playerNameController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: 'Nombre del jugador',
                                            hintStyle: const TextStyle(color: Colors.white54),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.1),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                          ),
                                          onSubmitted: (_) => addPlayer(playersProvider, context),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => addPlayer(playersProvider, context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF29B6F6),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: const Text(
                                          'Agregar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),

                                  // Lista de jugadores
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 150),
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: players.map((player) => PlayerTag(
                                          onRemove: () => _removePlayer(player),
                                          playerName: player,
                                        )).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            
                            // Divider
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                            ),

                            // Sección de modos de juego
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // Título modos de juego
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Elige Modo con Jugadores (${players.length}/2+)',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Grid de modos de juego
                                    _buildGameModesGrid(playersProvider),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}