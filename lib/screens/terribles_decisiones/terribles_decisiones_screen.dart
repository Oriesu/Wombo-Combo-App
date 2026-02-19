import 'package:flutter/material.dart';
import 'terribles_decisiones_logic.dart';

class TerriblesDecisionesScreen extends StatefulWidget {
  final List<String> players;

  const TerriblesDecisionesScreen({Key? key, required this.players}) : super(key: key);

  @override
  TerriblesDecisionesScreenState createState() => TerriblesDecisionesScreenState();
}

class TerriblesDecisionesScreenState extends State<TerriblesDecisionesScreen> {
  late TerriblesDecisionesLogic logic;


  @override
  void initState() {
    super.initState();
    logic = TerriblesDecisionesLogic();
  }

  void _generatePreferencia() {
    setState(() {
      logic.generatePreferencia();
    });
  }

  Widget _buildContentSection() {
    return AnimatedOpacity(
      opacity: logic.showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(top: 30, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
                Text(
                logic.currentPreferencia,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4CAF50),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '¡La minoría bebe!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Terribles Decisiones',
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

                    // Botón principal
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                      ),
                      child: ElevatedButton(
                        onPressed: _generatePreferencia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.4),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🗳️',
                              style: TextStyle(fontSize: 40),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '¿QUÉ PREFIERES?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sección de contenido 
                    if (logic.showContent) _buildContentSection(),
                    Expanded(
                      child: Container(),
                    ),

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
      ),
    );
  }
} 