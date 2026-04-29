import 'package:flutter/material.dart';
import 'ruleta_logic.dart';

class RuletaScreen extends StatefulWidget {
  final List<String> players;

  const RuletaScreen({Key? key, required this.players}) : super(key: key);

  @override
  RuletaScreenState createState() => RuletaScreenState();
}

class RuletaScreenState extends State<RuletaScreen> {
  late RuletaLogic logic;

  @override
  void initState() {
    super.initState();
    logic = RuletaLogic(widget.players);
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 12),
                    
                    // Mesa de apuestas
                    _buildMesaApuestas(),
                    
                    const SizedBox(height: 12),

                    // Jugadores
                    _buildJugadoresSection(),
                    
                    const Spacer(), 
                    
                    const SizedBox(height: 12),
                    
                    // Controles
                    _buildControles(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'Ruleta de Tragos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x26FF00CC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.white),
                children: [
                  const TextSpan(text: 'Turno de: '),
                  TextSpan(
                    text: logic.currentPlayer,
                    style: const TextStyle(
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
    );
  }

  Widget _buildMesaApuestas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildApuestaMensaje(),
            const SizedBox(height: 8),
            _buildContenedorPrincipal(),
          ],
        ),
      ),
    );
  }

  Widget _buildApuestaMensaje() {
    final apuesta = logic.getApuestaActual();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x1AFF00CC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4DFF00CC)),
      ),
      child: Text(
        apuesta != null 
            ? '${logic.currentPlayer} ha apostado a ${apuesta['tipo']} con ${_getTextoFicha(apuesta['ficha'])}'
            : '${logic.currentPlayer} aún no ha apostado',
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getTextoFicha(String tipoFicha) {
    final valor = logic.valoresFichas[tipoFicha]!;
    final esHidalgo = tipoFicha == 'hidalgo';
    final unidadTexto = esHidalgo ? 'hidalgo' : 'trago';
    final unidadTextoPlural = esHidalgo ? 'hidalgos' : 'tragos';
    return '$valor ${valor > 1 ? unidadTextoPlural : unidadTexto}';
  }

  Widget _buildContenedorPrincipal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Números de la ruleta Y FILA CERO
        Expanded(
          flex: 65,
          child: Column( 
            children: [
              _buildNumerosRuleta(),
              const SizedBox(height: 1), 
              _buildFilaCero(), 
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Contenedor derecho
        Expanded(
          flex: 35,
          child: _buildContenedorDerecho(),
        ),
      ],
    );
  }

  Widget _buildNumerosRuleta() {
    final numeros = [
      [34, 35, 36], [31, 32, 33], [28, 29, 30], [25, 26, 27],
      [22, 23, 24], [19, 20, 21], [16, 17, 18], [13, 14, 15],
      [10, 11, 12], [7, 8, 9], [4, 5, 6], [1, 2, 3]
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: 36,
      itemBuilder: (context, index) {
        final fila = index ~/ 3;
        final columna = index % 3;
        final numero = numeros[fila][columna];
        final color = logic.getColorNumero(numero);
        
        return _buildNumeroBtn(numero.toString(), color);
      },
    );
  }

  Widget _buildNumeroBtn(String texto, Color color) {
    return GestureDetector(
      onTap: () => _handleApuesta(texto),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getGradientColors(color),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(Color baseColor) {
    if (baseColor == const Color(0xFF2E7D32)) {
      return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
    } else if (baseColor == Colors.red) {
      return [const Color(0xFFD32F2F), const Color(0xFFB71C1C)];
    } else {
      return [const Color(0xFF212121), const Color(0xFF000000)];
    }
  }

  Widget _buildContenedorDerecho() {
    return Column(
      children: [
        // Apuestas externas
        _buildApuestasExternas(),
        const SizedBox(height: 6),
        
        // Grid de fichas (2x2)
        _buildFichasGrid(),
        const SizedBox(height: 6),
        
        // Ficha ampliada
        _buildFichaAmpliada(),
      ],
    );
  }

  Widget _buildApuestasExternas() {
    final apuestasExternas = [
      {'tipo': 'col1', 'texto': '2 to 1'},
      {'tipo': 'col2', 'texto': '2 to 1'},
      {'tipo': 'col3', 'texto': '2 to 1'},
      {'tipo': '1a12', 'texto': '1ª 12'},
      {'tipo': '2a12', 'texto': '2ª 12'},
      {'tipo': '3a12', 'texto': '3ª 12'},
      {'tipo': 'rojo', 'texto': 'ROJO', 'color': Colors.red},
      {'tipo': 'par', 'texto': 'PAR'},
      {'tipo': 'falta', 'texto': '1-18'},
      {'tipo': 'negro', 'texto': 'NEGRO', 'color': Colors.black},
      {'tipo': 'impar', 'texto': 'IMPAR'},
      {'tipo': 'pasa', 'texto': '19-36'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final apuesta = apuestasExternas[index];
        final color = apuesta['color'] as Color?;
        
        return _buildExternaBtn(
          apuesta['texto'] as String,
          apuesta['tipo'] as String,
          color,
        );
      },
    );
  }

  Widget _buildExternaBtn(String texto, String tipo, Color? color) {
    return GestureDetector(
      onTap: () => _handleApuesta(tipo),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: color == Colors.red 
                ? [const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
                : color == Colors.black
                  ? [const Color(0xFF212121), const Color(0xFF000000)]
                  : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFichasGrid() {
    final fichas = [
      {'tipo': '1', 'imagen': 'lib/screens/ruleta/fichas/ficha1.png'},
      {'tipo': '2', 'imagen': 'lib/screens/ruleta/fichas/ficha2.png'},
      {'tipo': '3', 'imagen': 'lib/screens/ruleta/fichas/ficha3.png'},
      {'tipo': 'hidalgo', 'imagen': 'lib/screens/ruleta/fichas/ficha4.png'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final ficha = fichas[index];
        final isSelected = logic.fichaSeleccionada == ficha['tipo'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              logic.seleccionarFicha(ficha['tipo']!);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSelected 
                  ? Border.all(color: const Color(0xFFFF00CC), width: 2)
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                ficha['imagen']!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFichaAmpliada() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFFF00CC), width: 2),
        ),
        child: ClipOval(
          child: Image.asset(
            _getFichaImagePath(logic.fichaSeleccionada),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _getFichaImagePath(String tipoFicha) {
    switch (tipoFicha) {
      case '1': return 'lib/screens/ruleta/fichas/ficha1.png';
      case '2': return 'lib/screens/ruleta/fichas/ficha2.png';
      case '3': return 'lib/screens/ruleta/fichas/ficha3.png';
      case 'hidalgo': return 'lib/screens/ruleta/fichas/ficha4.png';
      default: return 'lib/screens/ruleta/fichas/ficha1.png';
    }
  }

  Widget _buildFilaCero() {
    return GestureDetector(
      onTap: () => _handleApuesta('0'),
      child: Container(
        height: 30, 
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            '0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJugadoresSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'Jugadores:',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.players.map((player) {
              final apuesta = logic.apuestas[player];
              final isCurrent = logic.currentPlayer == player;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? const Color(0x4DFF00CC)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrent
                      ? Border.all(color: const Color(0xFFFF00CC))
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    if (apuesta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Apuesta: ${apuesta['tipo']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 7),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControles() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // ***** MODIFICACIÓN CRÍTICA: Se usa pop para activar el intersticial *****
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: const Text('← Volver'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton(
            onPressed: logic.puedePasarSiguiente() && !logic.ruletaGirando
                ? () {
                    setState(() {
                      logic.siguienteJugador();
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF0066FF).withOpacity(0.3),
              disabledForegroundColor: Colors.white.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              logic.esUltimoJugador() ? 'Último Jugador' : 'Siguiente',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton(
            onPressed: logic.todosHanApostado() && !logic.ruletaGirando
                ? _girarRuleta
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF00CC),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFFF00CC).withOpacity(0.3),
              disabledForegroundColor: Colors.white.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Girar Ruleta',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _handleApuesta(String tipoApuesta) {
    if (logic.ruletaGirando) return;
    
    setState(() {
      logic.agregarApuesta(tipoApuesta);
    });
  }

  void _girarRuleta() {
    setState(() {
      logic.ruletaGirando = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      final resultado = logic.girarRuleta();
      _mostrarResultados(resultado['numero'], resultado['color']);
    });
  }

  void _mostrarResultados(int numero, String color) {
    final resultados = logic.calcularResultados(numero, color);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Resultado de la Ruleta',
                style: TextStyle(
                  color: Color(0xFFFF00CC),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                numero.toString(),
                style: const TextStyle(
                  color: Color(0xFF00CCFF),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Color: $color',
                style: TextStyle(
                  color: color == 'rojo' 
                      ? Colors.red 
                      : color == 'negro' 
                        ? Colors.black 
                        : Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...resultados.map((resultado) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultado['jugador'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                   const SizedBox(height: 2),
                    Text(
                      resultado['detalle'],
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resultado['resultado'],
                      style: TextStyle(
                        color: resultado['tragos'] > 0 
                            ? const Color(0xFF00FF00)
                            : resultado['tragos'] < 0
                              ? const Color(0xFFFF4444)
                              : const Color(0xFFCCCCCC),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    logic.reiniciarParaSiguienteRonda();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF00CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}