// Archivo: lib/screens/123/123_screen.dart

import 'package:flutter/material.dart';
import '../add_players/add_players_screen.dart';
import '123_logic.dart';

class OneTwoThreeScreen extends StatefulWidget {
  final List<String> players;

  const OneTwoThreeScreen({Key? key, required this.players}) : super(key: key);

  @override
  _OneTwoThreeScreenState createState() => _OneTwoThreeScreenState();
}

class _OneTwoThreeScreenState extends State<OneTwoThreeScreen> {
  late OneTwoThreeLogic logic;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    logic = OneTwoThreeLogic(widget.players);
    
    // Configurar callbacks
    logic.onTimerChanged = _onTimerChanged;
    logic.onChallengeChanged = _onChallengeChanged;
    logic.onPlayerChanged = _onPlayerChanged;
    
    // Iniciar el primer turno
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.startTimer();
    });
  }

  void _onTimerChanged(int timeLeft) {
    setState(() {
      _showWarning = timeLeft <= 5;
    });
  }

  void _onChallengeChanged(String challenge) {
    setState(() {});
  }

  void _onPlayerChanged(String player) {
    setState(() {});
  }

  void _nextPlayer() {
    setState(() {
      logic.nextPlayer();
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '1, 2, 3',
            style: TextStyle(
              fontSize: 40,
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
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Turno de: ',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  TextSpan(
                    text: logic.currentPlayer,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFC107),
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Color(0xFFFFC107),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '¡Cita 3 cosas en 10 segundos!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            constraints: const BoxConstraints(minHeight: 180),
            child: Center(
              child: Text(
                logic.currentChallenge,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFC107),
                  height: 1.6,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Color(0xFFFFC107),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w800,
              color: _showWarning ? const Color(0xFFFF6B6B) : const Color(0xFF00CCFF),
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            child: Text(
              logic.timeLeft.toString(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'segundos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0033),
      body: Stack( // CAMBIO 1: Usar Stack en lugar de Container
        children: [
          // Fondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a0033), Color(0xFF330033)],
              ),
            ),
          ),
          
          // Contenido principal scrollable (con header)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView( // CAMBIO 2: Mover SingleChildScrollView aquí
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 25),
                        _buildChallengeSection(),
                        const SizedBox(height: 25),
                        _buildTimerSection(),
                        const SizedBox(height: 100), // Espacio para los botones fijos
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Botones inferiores FIJOS (fuera del scroll)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: ElevatedButton(
                          onPressed: _nextPlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Siguiente Jugador',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }
}