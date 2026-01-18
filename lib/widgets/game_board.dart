import 'package:flutter/material.dart';
import 'dart:math';

// Configuración del tablero basada en el CSV proporcionado
const List<Map<String, dynamic>> boardConfig = [
  // Fila 1 (izquierda a derecha) - Casillas 1-10
  {'type': 'start', 'number': 1, 'content': '🏁'},
  {'type': 'beber', 'number': 2, 'content': '🍺'},
  {'type': 'yo-nunca', 'number': 3, 'content': '🙅‍♂️'},
  {'type': '123', 'number': 4, 'content': 'podium'},
  {'type': 'challenge', 'number': 5, 'content': '⚡'},
  {'type': 'verdad', 'number': 6, 'content': '❓'},
  {'type': 'rule', 'number': 7, 'content': '📜'},
  {'type': 'preferencias', 'number': 8, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 9, 'content': '🙅‍♂️'},
  {'type': 'quien-mas', 'number': 10, 'content': '👥'},
  
  // Fila 2 (derecha a izquierda) - Casillas 11-20
  {'type': 'quien-mas', 'number': 20, 'content': '👥'},
  {'type': '123', 'number': 19, 'content': 'podium'},
  {'type': 'challenge', 'number': 18, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 17, 'content': '🙅‍♂️'},
  {'type': 'preferencias', 'number': 16, 'content': '🤔'},
  {'type': '123', 'number': 15, 'content': 'podium'},
  {'type': 'verdad', 'number': 14, 'content': '❓'},
  {'type': 'yo-nunca', 'number': 13, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 12, 'content': '⚡'},
  {'type': '123', 'number': 11, 'content': 'podium'},

  // Fila 3 (izquierda a derecha) - Casillas 21-30
  {'type': 'yo-nunca', 'number': 21, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 22, 'content': '❓'},
  {'type': '123', 'number': 23, 'content': 'podium'},
  {'type': 'preferencias', 'number': 24, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 25, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 26, 'content': '⚡'},
  {'type': '123', 'number': 27, 'content': 'podium'},
  {'type': 'quien-mas', 'number': 28, 'content': '👥'},
  {'type': 'yo-nunca', 'number': 29, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 30, 'content': '❓'},
  
  // Fila 4 (derecha a izquierda) - Casillas 31-40
  {'type': '123', 'number': 40, 'content': 'podium'},
  {'type': 'verdad', 'number': 39, 'content': '❓'},
  {'type': 'yo-nunca', 'number': 38, 'content': '🙅‍♂️'},
  {'type': 'quien-mas', 'number': 37, 'content': '👥'},
  {'type': '123', 'number': 36, 'content': 'podium'},
  {'type': 'challenge', 'number': 35, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 34, 'content': '🙅‍♂️'},
  {'type': 'drink', 'number': 33, 'content': '🥃'},
  {'type': 'preferencias', 'number': 32, 'content': '🤔'},
  {'type': '123', 'number': 31, 'content': 'podium'},
  
  // Fila 5 (izquierda a derecha) - Casillas 41-50
  {'type': 'preferencias', 'number': 41, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 42, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 43, 'content': '⚡'},
  {'type': '123', 'number': 44, 'content': 'podium'},
  {'type': 'beber', 'number': 45, 'content': '🍺'},
  {'type': 'yo-nunca', 'number': 46, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 47, 'content': '❓'},
  {'type': '123', 'number': 48, 'content': 'podium'},
  {'type': 'preferencias', 'number': 49, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 50, 'content': '🙅‍♂️'},
  
  // Fila 6 (derecha a izquierda) - Casillas 51-60
  {'type': '123', 'number': 60, 'content': 'podium'},
  {'type': 'challenge', 'number': 59, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 58, 'content': '🙅‍♂️'},
  {'type': 'preferencias', 'number': 57, 'content': '🤔'},
  {'type': '123', 'number': 56, 'content': 'podium'},
  {'type': 'verdad', 'number': 55, 'content': '❓'},
  {'type': 'yo-nunca', 'number': 54, 'content': '🙅‍♂️'},
  {'type': 'quien-mas', 'number': 53, 'content': '👥'},
  {'type': '123', 'number': 52, 'content': 'podium'},
  {'type': 'challenge', 'number': 51, 'content': '⚡'},
  
  // Fila 7 (izquierda a derecha) - Casillas 61-70
  {'type': 'yo-nunca', 'number': 61, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 62, 'content': '❓'},
  {'type': '123', 'number': 63, 'content': 'podium'},
  {'type': 'preferencias', 'number': 64, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 65, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 66, 'content': '⚡'},
  {'type': '123', 'number': 67, 'content': 'podium'},
  {'type': 'quien-mas', 'number': 68, 'content': '👥'},
  {'type': 'drink', 'number': 69, 'content': '🥃'},
  {'type': 'yo-nunca', 'number': 70, 'content': '🙅‍♂️'},
  
  // Fila 8 (derecha a izquierda) - Casillas 71-80
  {'type': 'end', 'number': 80, 'content': '🏆'},
  {'type': 'beber', 'number': 79, 'content': '🍺'},
  {'type': 'challenge', 'number': 78, 'content': '⚡'},
  {'type': '123', 'number': 77, 'content': 'podium'},
  {'type': 'verdad', 'number': 76, 'content': '❓'},
  {'type': 'yo-nunca', 'number': 75, 'content': '🙅‍♂️'},
  {'type': 'preferencias', 'number': 74, 'content': '🤔'},
  {'type': 'friki', 'number': 73, 'content': '🤓'},
  {'type': '123', 'number': 72, 'content': 'podium'},
  {'type': 'challenge', 'number': 71, 'content': '⚡'}
];

class GameBoard extends StatelessWidget {
  final List<String> players;
  final List<int> playerPositions;
  final Color Function(int) getPlayerColor;

  const GameBoard({
    Key? key,
    required this.players,
    required this.playerPositions,
    required this.getPlayerColor,
  }) : super(key: key);

  Color _getCellColor(String type) {
    switch (type) {
      case 'start':
        return const Color(0xFF00CCFF);
      case 'end':
        return const Color(0xFF483D8B);
      case 'rule':
        return const Color(0xFFFF4500);
      case 'challenge':
        return const Color(0xFFFF00CC);
      case 'yo-nunca':
        return const Color(0xFF00FF88);
      case 'friki':
        return const Color(0xFF9966FF);
      case 'quien-mas':
        return const Color(0xFFFFC107);
      case '123':
        return const Color(0xFF556B2F);
      case 'verdad':
        return const Color(0xFF00CCFF);
      case 'drink':
        return const Color(0xFFFF6B6B);
      case 'beber':
        return const Color(0xFFF57C00);
      case 'preferencias':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF666666);
    }
  }

  Widget _buildContent(Map<String, dynamic> cell, double cellSize) {
    final content = cell['content'] as String;
    
    // Si el contenido es "podium", mostrar imagen PNG
    if (content == 'podium') {
      return Image.asset(
        'assets/images/podium.png',
        width: cellSize * 0.6,  
        height: cellSize * 0.6,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback a emoji si la imagen no carga
          return Text(
            '🔢',
            style: TextStyle(
              fontSize: max(cellSize * 0.35, 12),
              shadows: [
                Shadow(
                  blurRadius: 1,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Para otros contenidos (emojis), mostrar texto
    return Text(
      content,
      style: TextStyle(
        fontSize: max(cellSize * 0.35, 12),
        shadows: [
          Shadow(
            blurRadius: 1,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCell(Map<String, dynamic> cell, double cellSize) {
    final cellPlayers = <Widget>[];
    final markerSize = max(cellSize * 0.18, 4.0);
    
    // Agregar marcadores de jugadores en esta casilla
    for (int i = 0; i < players.length; i++) {
      if (playerPositions[i] == cell['number']) {
        cellPlayers.add(
          Positioned(
            bottom: 4,
            right: 4 + (i * markerSize * 0.6),
            child: Container(
              width: markerSize,
              height: markerSize,
              decoration: BoxDecoration(
                color: getPlayerColor(i),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(0.3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCellColor(cell['type']),
            _getCellColor(cell['type']).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getCellColor(cell['type']),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // CONTENIDO PRINCIPAL 
          Center(
            child: _buildContent(cell, cellSize),
          ),
          
          // NÚMERO DE LA CASILLA 
          Positioned(
            top: 1,
            left: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35), 
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                cell['number'].toString(),
                style: TextStyle(
                  fontSize: max(cellSize * 0.15, 8),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Marcadores de jugadores
          ...cellPlayers,
        ],
      ),
    );
  }

  List<Widget> _buildBoardRows(double cellSize) {
    List<Widget> rows = [];
    
    // Dividir las 80 casillas en 8 filas de 10 casillas cada una
    for (int row = 0; row < 8; row++) {
      List<Widget> rowCells = [];
      for (int col = 0; col < 10; col++) {
        int index = row * 10 + col;
        if (index < boardConfig.length) {
          rowCells.add(
            SizedBox(
              width: cellSize,
              height: cellSize,
              child: _buildBoardCell(boardConfig[index], cellSize),
            ),
          );
        }
      }
      
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowCells,
        ),
      );
      
      // Agregar espacio entre filas
      if (row < 7) {
        rows.add(const SizedBox(height: 8));
      }
    }
    
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calcular el tamaño de celda basado en el ancho disponible
          final cellSize = (constraints.maxWidth - 9) / 10;
          final totalHeight = (cellSize * 8) + 56;
          
          return SizedBox(
            height: totalHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildBoardRows(cellSize),
            ),
          );
        },
      ),
    );
  }
}