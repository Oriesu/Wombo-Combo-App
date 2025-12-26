import 'package:flutter/material.dart';
import 'dart:math';

// Configuración del tablero
const List<Map<String, dynamic>> boardConfig = [
  // Fila 1 (izquierda a derecha) - Casillas 1-10
  {'type': 'start', 'number': 1, 'content': '🏁'},
  {'type': '123', 'number': 2, 'content': 'podium'},
  {'type': 'verdad', 'number': 3, 'content': '❓'},
  {'type': 'quien-mas', 'number': 4, 'content': '🤔'},
  {'type': '123', 'number': 5, 'content': 'podium'},
  {'type': 'rule', 'number': 6, 'content': '📜'},
  {'type': 'rule', 'number': 7, 'content': '📜'},
  {'type': 'challenge', 'number': 8, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 9, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 10, 'content': '⚡'},
  
  // Fila 2 (derecha a izquierda) - Casillas 11-20
  {'type': 'yo-nunca', 'number': 20, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 19, 'content': '❓'},
  {'type': 'quien-mas', 'number': 18, 'content': '🤔'},
  {'type': '123', 'number': 17, 'content': 'podium'},
  {'type': 'yo-nunca', 'number': 16, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 15, 'content': '⚡'},
  {'type': '123', 'number': 14, 'content': 'podium'},
  {'type': 'verdad', 'number': 13, 'content': '❓'},
  {'type': 'quien-mas', 'number': 12, 'content': '🤔'},
  {'type': '123', 'number': 11, 'content': 'podium'},
  
  // Fila 3 (izquierda a derecha) - Casillas 21-30
  {'type': '123', 'number': 21, 'content': 'podium'},
  {'type': 'challenge', 'number': 22, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 23, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 24, 'content': '❓'},
  {'type': 'quien-mas', 'number': 25, 'content': '🤔'},
  {'type': '123', 'number': 26, 'content': 'podium'},
  {'type': 'yo-nunca', 'number': 27, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 28, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 29, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 30, 'content': '❓'},
  
  // Fila 4 (derecha a izquierda) - Casillas 31-40
  {'type': 'quien-mas', 'number': 40, 'content': '🤔'},
  {'type': '123', 'number': 39, 'content': 'podium'},
  {'type': 'verdad', 'number': 38, 'content': '❓'},
  {'type': 'challenge', 'number': 37, 'content': '⚡'},
  {'type': 'verdad', 'number': 36, 'content': '❓'},
  {'type': 'challenge', 'number': 35, 'content': '⚡'},
  {'type': 'friki', 'number': 34, 'content': '🤓'},
  {'type': 'drink', 'number': 33, 'content': '🍻'},
  {'type': 'quien-mas', 'number': 32, 'content': '🤔'},
  {'type': 'challenge', 'number': 31, 'content': '⚡'},
  
  // Fila 5 (izquierda a derecha) - Casillas 41-50
  {'type': 'yo-nunca', 'number': 41, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 42, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 43, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 44, 'content': '❓'},
  {'type': '123', 'number': 45, 'content': 'podium'},
  {'type': 'quien-mas', 'number': 46, 'content': '🤔'},
  {'type': 'yo-nunca', 'number': 47, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 48, 'content': '⚡'},
  {'type': 'verdad', 'number': 49, 'content': '❓'},
  {'type': 'rule', 'number': 50, 'content': '📜'},
  
  // Fila 6 (derecha a izquierda) - Casillas 51-60
  {'type': 'verdad', 'number': 60, 'content': '❓'},
  {'type': 'quien-mas', 'number': 59, 'content': '🤔'},
  {'type': '123', 'number': 58, 'content': 'podium'},
  {'type': 'yo-nunca', 'number': 57, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 56, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 55, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 54, 'content': '❓'},
  {'type': 'quien-mas', 'number': 53, 'content': '🤔'},
  {'type': '123', 'number': 52, 'content': 'podium'},
  {'type': 'quien-mas', 'number': 51, 'content': '🤔'},
  
  // Fila 7 (izquierda a derecha) - Casillas 61-70
  {'type': 'challenge', 'number': 61, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 62, 'content': '🙅‍♂️'},
  {'type': 'verdad', 'number': 63, 'content': '❓'},
  {'type': 'quien-mas', 'number': 64, 'content': '🤔'},
  {'type': '123', 'number': 65, 'content': 'podium'},
  {'type': 'rule', 'number': 66, 'content': '📜'},
  {'type': 'challenge', 'number': 67, 'content': '⚡'},
  {'type': 'yo-nunca', 'number': 68, 'content': '🙅‍♂️'},
  {'type': 'drink', 'number': 69, 'content': '🍻'},
  {'type': 'verdad', 'number': 70, 'content': '❓'},
  
  // Fila 8 (derecha a izquierda) - Casillas 71-80
  {'type': 'end', 'number': 80, 'content': '🎉'},
  {'type': 'quien-mas', 'number': 79, 'content': '🤔'},
  {'type': '123', 'number': 78, 'content': 'podium'},
  {'type': 'yo-nunca', 'number': 77, 'content': '🙅‍♂️'},
  {'type': 'challenge', 'number': 76, 'content': '⚡'},
  {'type': 'quien-mas', 'number': 75, 'content': '🤔'},
  {'type': 'verdad', 'number': 74, 'content': '❓'},
  {'type': 'friki', 'number': 73, 'content': '🤓'},
  {'type': 'challenge', 'number': 72, 'content': '⚡'},
  {'type': 'quien-mas', 'number': 71, 'content': '🤔'}
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