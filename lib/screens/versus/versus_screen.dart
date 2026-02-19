import 'package:flutter/material.dart'; 
import 'versus_logic.dart';

class VersusScreen extends StatefulWidget {
  final List<String> players;

  const VersusScreen({Key? key, required this.players}) : super(key: key);

  @override
  VersusScreenState createState() => VersusScreenState();
}

class VersusScreenState extends State<VersusScreen> {
  late VersusLogic logic;
  bool _showTeamsModal = false;

  @override
  void initState() {
    super.initState();
    logic = VersusLogic();
    _initializeGame();
  }

  void _initializeGame() {
    try {
      logic.initializeTeams(widget.players);
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    });
  }

  void _showNextChallenge() {
    setState(() {
      logic.showNextChallenge();
    });
  }

  void _toggleTeamsModal() {
    setState(() {
      _showTeamsModal = !_showTeamsModal;
    });
  }

  Widget _buildChallengeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Desafío del Turno',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),
          _buildActionButton(
            text: 'Siguiente Desafío',
            color: const Color(0xFFFFCC00),
            onTap: _showNextChallenge,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return AnimatedOpacity(
      opacity: logic.showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                logic.currentContent,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: _buildActionButton(
        text: 'Ver Equipos',
        color: const Color(0xFF0066FF),
        onTap: _toggleTeamsModal,
      ),
    );
  }

  Widget _buildTeamsModal() {
    return GestureDetector(
      onTap: _toggleTeamsModal,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1a0033), Color(0xFF330033)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Equipos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF00CC),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamDisplay(
                          teamName: 'Equipo Azul',
                          players: logic.teamBlue,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTeamDisplay(
                          teamName: 'Equipo Rojo',
                          players: logic.teamRed,
                          color: const Color(0xFFFF0000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    text: 'Cerrar',
                    color: const Color(0xFFFF00CC),
                    onTap: _toggleTeamsModal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDisplay({
    required String teamName,
    required List<String> players,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: players.map((player) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border(left: BorderSide(color: color, width: 4)),
              ),
              child: Text(
                player,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0033),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a0033), Color(0xFF330033)],
              ),
            ),
          ),
          
          // Contenido principal scrollable
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(25),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Modo Versus',
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

                        const SizedBox(height: 25),

                        // Sección de desafío
                        _buildChallengeSection(),

                        const SizedBox(height: 25),

                        // Sección de contenido
                        if (logic.showContent) ...[
                          _buildContentSection(),
                          const SizedBox(height: 25),
                        ],

                        // Sección de equipos
                        _buildTeamsSection(),
                        
                        // Espacio para los botones fijos
                        const SizedBox(height: 120), 
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Botones inferiores FIJOS 
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de volver
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Volver',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showTeamsModal)
            _buildTeamsModal(),
        ],
      ),
    );
  }
}