// Archivo: lib/screens/terribles_decisiones/terribles_decisiones_screen.dart

import 'package:flutter/material.dart';
import '../add_players/add_players_screen.dart';
import 'terribles_decisiones_logic.dart';

// ***** MODIFICACIÓN AQUÍ *****
import 'dart:io' show Platform;
import 'package:unity_ads_plugin/unity_ads_plugin.dart';


class TerriblesDecisionesScreen extends StatefulWidget {
  final List<String> players;

  const TerriblesDecisionesScreen({Key? key, required this.players}) : super(key: key);

  @override
  _TerriblesDecisionesScreenState createState() => _TerriblesDecisionesScreenState();
}

class _TerriblesDecisionesScreenState extends State<TerriblesDecisionesScreen> {
  late TerriblesDecisionesLogic logic;

  // ***** MODIFICACIÓN AQUÍ *****
  String get bannerPlacementId => Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS';
  // -----------------------------

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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
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
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
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
          // ***** MODIFICACIÓN AQUÍ: Se añade Stack para el banner *****
          child: Stack(
            children: [
              Center(
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
                              shadowColor: Colors.black.withOpacity(0.4),
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

                        // Sección de contenido (aparece debajo del botón)
                        if (logic.showContent) _buildContentSection(),

                        // Espacio flexible para empujar el botón de volver hacia abajo
                        Expanded(
                          child: Container(),
                        ),

                        // Botón de volver - en la parte inferior
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              // ***** MODIFICACIÓN CRÍTICA: Se usa pop para activar el intersticial *****
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
                        
                        // ***** MODIFICACIÓN AQUÍ: Espacio reservado para el banner *****
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),

              // ***** MODIFICACIÓN AQUÍ: Banner de Unity Ads *****
              if (Platform.isAndroid || Platform.isIOS)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: UnityBannerAd(
                    placementId: bannerPlacementId,
                    onLoad: (placementId) => print('Banner TD cargado: $placementId'),
                    onFailed: (placementId, error, message) => print('Error Banner TD: $message'),
                  ),
                ),
            ],
          ),
          // -------------------------------------------------------------
        ),
      ),
    );
  }
}