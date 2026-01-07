import 'package:flutter/material.dart';
import '../add_players/add_players_screen.dart';
import 'caballos_logic.dart';

class CaballosScreen extends StatefulWidget {
  final List<String> players;

  const CaballosScreen({Key? key, required this.players}) : super(key: key);

  @override
  _CaballosScreenState createState() => _CaballosScreenState();
}

class _CaballosScreenState extends State<CaballosScreen> {
  late CaballosLogic logic;

  @override
  void initState() {
    super.initState();
    logic = CaballosLogic();
    logic.initializeGame();
  }

  void _drawCard() {
    setState(() {
      logic.drawCard();
    });
  }

  void _resetGame() {
    setState(() {
      logic.resetGame();
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: const Text(
        'Carrera de Caballos',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTrack() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildStartLine(),
          const SizedBox(height: 10),
          ...List.generate(CaballosLogic.totalStages, (index) => _buildTrackStage(index)),
          _buildFinishLine(),
        ],
      ),
    );
  }

  Widget _buildStartLine() {
    final horsesAtStart = logic.horses.entries
        .where((entry) => entry.value.position == 0 && !entry.value.finished)
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: horsesAtStart.isNotEmpty
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: horsesAtStart
                        .map((entry) => _buildHorse(entry.value))
                        .toList(),
                  )
                : const SizedBox(height: 85),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStage(int stageIndex) {
    final isFlipped = logic.flippedStages[stageIndex];
    final carta = logic.trackCards[stageIndex];
    final horsesAtStage = logic.horses.entries
        .where((entry) => entry.value.position == stageIndex + 1 && !entry.value.finished)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildStageCard(carta, isFlipped),
          const SizedBox(width: 8),
          Expanded(
            child: horsesAtStage.isNotEmpty
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: horsesAtStage
                        .map((entry) => _buildHorse(entry.value))
                        .toList(),
                  )
                : const SizedBox(height: 85),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(Carta carta, bool isFlipped) {
    return Container(
      width: 55,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isFlipped
        ? Image.asset(carta.imagePath, fit: BoxFit.cover)
        : Image.asset('lib/screens/caballos/barajaEsp/Reverso.png', fit: BoxFit.cover),
    );
  }

  Widget _buildFinishLine() {
    final finishedHorses = logic.horses.entries
        .where((entry) => entry.value.finished)
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFC107)),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 85,
            child: const Center(
              child: Text(
                'META',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: finishedHorses.isNotEmpty
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: finishedHorses
                        .map((entry) => _buildHorse(entry.value))
                        .toList(),
                  )
                : const SizedBox(height: 85),
          ),
        ],
      ),
    );
  }

  Widget _buildHorse(Horse horse) {
    return Container(
      width: 65,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Image.asset(horse.card.imagePath, fit: BoxFit.cover),
        ],
      ),
    );
  }

  Widget _buildDeckArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDiscardPile(),
          _buildBetMessage(),
          _buildDeck(),
        ],
      ),
    );
  }

  Widget _buildDiscardPile() {
    return Column(
      children: [
        const Text('Descartes', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          width: 55,
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: logic.discardPile.isNotEmpty
              ? Image.asset(logic.discardPile.last.imagePath, fit: BoxFit.cover)
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(child: Text('Vacío', style: TextStyle(color: Colors.white54, fontSize: 11))),
                ),
        ),
      ],
    );
  }

  Widget _buildBetMessage() {
    return Container(
      width: 120,
      height: 85,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFC107)),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(
            '¡Hagan sus apuestas!',
            style: TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDeck() {
    return Column(
      children: [
        const Text('Mazo', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          width: 55,
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: logic.deckCount > 0
              ? Image.asset('lib/screens/caballos/barajaEsp/Reverso.png', fit: BoxFit.cover)
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(child: Text('Vacío', style: TextStyle(color: Colors.white54, fontSize: 11))),
                ),
        ),
        const SizedBox(height: 3),
        Text('${logic.deckCount} cartas', style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButton() {
    final isGameFinished = logic.isGameFinished;
    
    return GestureDetector(
      onTap: isGameFinished ? _resetGame : _drawCard,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF00CC), Color(0xFFCC00FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF00CC).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          isGameFinished ? 'Jugar Otra Vez' : 'Sacar Carta',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          textAlign: TextAlign.center,
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
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTrack(),
                            const SizedBox(height: 20),
                            _buildDeckArea()
                          ]
                        )
                      )
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.white.withOpacity(0.2))),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_back, size: 16), SizedBox(width: 6), Text('Volver', style: TextStyle(fontWeight: FontWeight.w500))]),
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