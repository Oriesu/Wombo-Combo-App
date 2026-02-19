import 'package:flutter/material.dart';
import 'verdad_reto_logic.dart';

class VerdadRetoScreen extends StatefulWidget {
  final List<String> players;

  const VerdadRetoScreen({Key? key, required this.players}) : super(key: key);

  @override
  VerdadRetoScreenState createState() => VerdadRetoScreenState();
}

class VerdadRetoScreenState extends State<VerdadRetoScreen> {
  late VerdadRetoLogic logic;

  @override
  void initState() {
    super.initState();
    logic = VerdadRetoLogic();
  }

  void _showVerdad() {
    setState(() {
      logic.showVerdad(widget.players);
    });
  }

  void _showReto() {
    setState(() {
      logic.showReto(widget.players);
    });
  }

  Widget _buildChoiceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Elige:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  icon: '❓',
                  text: 'VERDAD',
                  color: const Color(0xFF00CCFF),
                  onTap: _showVerdad,
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: _buildChoiceButton(
                  icon: '⚡',
                  text: 'RETO',
                  color: const Color(0xFFFF00CC),
                  onTap: _showReto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: logic.isVerdad 
                  ? const Color(0xFF00CCFF).withOpacity(0.3)
                  : const Color(0xFFFF00CC).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            logic.currentContent,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: logic.isVerdad ? const Color(0xFF00CCFF) : const Color(0xFFFF00CC),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Jugadores:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: widget.players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final isCurrent = index == logic.getCurrentPlayerIndex(widget.players);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? const Color(0xFFFF00CC).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: isCurrent
                      ? Border.all(color: const Color(0xFFFF00CC))
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF00CC).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  player,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
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
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Verdad o Reto',
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
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF00CC).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Turno de: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: logic.getCurrentPlayer(widget.players),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFF00CC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Sección de elección
                        _buildChoiceSection(),

                        const SizedBox(height: 25),

                        // Sección de contenido 
                        if (logic.showContent) ...[
                          _buildContentSection(),
                          const SizedBox(height: 25),
                        ],

                        // Sección de jugadores
                        _buildPlayersSection(),
                        
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
}