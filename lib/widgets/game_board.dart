import 'package:flutter/material.dart';
import 'dart:math';

// Lista de iconos disponibles para los jugadores
const List<String> playerIcons = [
  'aguardiente.png',
  'amaretto-sour.png',
  'anis.png',
  'cerveza-negra.png',
  'champagne.png',
  'conac.png',
  'gin-tonic.png',
  'glass.png',
  'jagermeister.png',
  'kahlua.png',
  'limoncello.png',
  'mojito.png',
  'orujo.png',
  'rum.png',
  'sangria.png',
  'sidra.png',
  'vermut.png',
  'vodka.png',
  'whiskey.png',
  'wine-bottle.png',
];

class GameBoard extends StatelessWidget {
  final List<String> players;
  final List<int> playerPositions;
  final Color Function(int) getPlayerColor;
  final List<Map<String, dynamic>> boardConfig;

  // Constructor SIN la palabra 'const' porque tiene lógica en el cuerpo
  GameBoard({
    Key? key,
    required this.players,
    required this.playerPositions,
    required this.getPlayerColor,
    required this.boardConfig,
  }) : super(key: key) {
    // Este cuerpo NO está permitido en un constructor const
    debugPrint('[GAME BOARD] ===== CONSTRUIDO =====');
    debugPrint('[GAME BOARD] Players: $players');
    debugPrint('[GAME BOARD] Posiciones: $playerPositions');
    debugPrint('[GAME BOARD] Configuración del tablero: ${boardConfig.length} casillas');
    if (boardConfig.isNotEmpty) {
      debugPrint('[GAME BOARD] Primera casilla: ${boardConfig[0]}');
    } else {
      debugPrint('[GAME BOARD] ¡ADVERTENCIA! boardConfig está vacío');
    }
    debugPrint('[GAME BOARD] =====================');
  }

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
      case 'comunista':
        return const Color(0xFFFF0000);
      default:
        return const Color(0xFF666666);
    }
  }

  Widget _buildContent(Map<String, dynamic> cell, double cellSize) {
    final content = cell['content'] as String;
    
    if (content == 'podium') {
      return Image.asset(
        'assets/images/podium.png',
        width: cellSize * 0.6,
        height: cellSize * 0.6,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[GAME BOARD] Error cargando podium.png: $error');
          return Text(
            '🔢',
            style: TextStyle(fontSize: max(cellSize * 0.35, 12)),
          );
        },
      );
    }
    
    return Text(
      content,
      style: TextStyle(fontSize: max(cellSize * 0.35, 12)),
    );
  }

  // Obtener el icono para un jugador específico
  String _getPlayerIconPath(int playerIndex) {
    final iconIndex = playerIndex % playerIcons.length;
    return 'lib/screens/wombo_combo/iconos/${playerIcons[iconIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    // Verificar que hay datos para mostrar
    if (boardConfig.isEmpty) {
      debugPrint('[GAME BOARD] ERROR: boardConfig está vacío');
      return Container(
        height: 200,
        color: Colors.red.withOpacity(0.3),
        child: const Center(
          child: Text(
            'Error: Tablero no configurado',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black54,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          border: Border.all(
            color: Colors.black87,
            width: 1.5,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 10;
            final cellHeight = cellWidth * 1.25;
            final totalHeight = cellHeight * 8;
            
            debugPrint('[GAME BOARD] Dimensiones: ancho=${constraints.maxWidth}, cellWidth=$cellWidth, cellHeight=$cellHeight, totalHeight=$totalHeight');
            
            return SizedBox(
              height: totalHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildBoardRows(cellWidth, cellHeight),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBoardRows(double cellWidth, double cellHeight) {
    List<Widget> rows = [];
    
    for (int row = 0; row < 8; row++) {
      List<Widget> rowCells = [];
      
      for (int col = 0; col < 10; col++) {
        int index = row * 10 + col;
        if (index < boardConfig.length) {
          final cell = boardConfig[index];
          final cellNumber = cell['number'] as int;
          
          // Determinar si esta casilla está en una unión
          final bool isTransitionTop = cellNumber == 11 || cellNumber == 21 || 
                                      cellNumber == 31 || cellNumber == 41 || 
                                      cellNumber == 51 || cellNumber == 61 || cellNumber == 71;
          
          final bool isTransitionBottom = cellNumber == 10 || cellNumber == 20 || 
                                         cellNumber == 30 || cellNumber == 40 || 
                                         cellNumber == 50 || cellNumber == 60 || cellNumber == 70;
          
          final bool isFirstRow = row == 0;
          final bool isLastRow = row == 7;
          final bool isFirstCol = col == 0;
          final bool isLastCol = col == 9;
          
          // CONSTRUCCIÓN DE BORDES SIN DUPLICACIÓN
          BorderSide topBorder = BorderSide.none;
          BorderSide bottomBorder = BorderSide.none;
          BorderSide leftBorder = BorderSide.none;
          BorderSide rightBorder = BorderSide.none;
          
          // BORDE SUPERIOR: solo lo pone la primera fila o las casillas de inicio de unión
          if (isFirstRow) {
            topBorder = const BorderSide(color: Colors.black45, width: 0.5);
          } else if (isTransitionTop) {
            topBorder = const BorderSide(color: Colors.black45, width: 0.5);
          }
          
          // BORDE INFERIOR: solo lo pone la última fila o las casillas de fin de unión
          if (isLastRow) {
            bottomBorder = const BorderSide(color: Colors.black45, width: 0.5);
          } else if (isTransitionBottom) {
            bottomBorder = const BorderSide(color: Colors.black45, width: 0.5);
          } else {
            // Si no es última fila ni transición, ponemos borde inferior GRUESO
            bottomBorder = const BorderSide(color: Colors.black87, width: 2.3);
          }
          
          // BORDE IZQUIERDO: solo lo pone la primera columna
          if (isFirstCol) {
            leftBorder = const BorderSide(color: Colors.black45, width: 0.5);
          }
          
          // BORDE DERECHO: solo lo pone la última columna
          if (isLastCol) {
            rightBorder = const BorderSide(color: Colors.black45, width: 0.5);
          }
          
          rowCells.add(
            SizedBox(
              width: cellWidth,
              height: cellHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: _getCellColor(cell['type']).withOpacity(0.9),
                  border: Border(
                    top: topBorder,
                    bottom: bottomBorder,
                    left: leftBorder,
                    right: rightBorder,
                  ),
                ),
                child: Stack(
                  children: [
                    // Contenido principal
                    Center(child: _buildContent(cell, cellWidth)),
                    
                    // Número de casilla
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
                            fontSize: max(cellWidth * 0.15, 8),
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
                    
                    // Marcadores de jugadores con iconos
                    ..._getPlayerMarkers(cellNumber, cellWidth),
                  ],
                ),
              ),
            ),
          );
        }
      }
      
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: rowCells,
      ));
    }
    
    return rows;
  }

  List<Widget> _getPlayerMarkers(int cellNumber, double cellSize) {
    List<Widget> markers = [];
    final markerSize = max(cellSize * 0.54, 24.0);
    final overlapFactor = 0.40;
    final maxPlayersPerCell = 3;
    
    // Agrupamos los marcadores de esta casilla
    List<int> playersInCell = [];
    for (int i = 0; i < players.length; i++) {
      if (playerPositions[i] == cellNumber) {
        playersInCell.add(i);
      }
    }
    
    // Si hay jugadores en esta casilla, los posicionamos
    final playersToShow = playersInCell.length > maxPlayersPerCell 
        ? playersInCell.sublist(0, maxPlayersPerCell) 
        : playersInCell;
    
    final bool hasMorePlayers = playersInCell.length > maxPlayersPerCell;
    
    for (int index = 0; index < playersToShow.length; index++) {
      final playerIndex = playersToShow[index];
      final rightMargin = (index * markerSize * overlapFactor);
      
      markers.add(
        Positioned(
          bottom: 1,
          right: rightMargin,
          child: Image.asset(
            _getPlayerIconPath(playerIndex),
            width: markerSize,
            height: markerSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[GAME BOARD] Error cargando icono para jugador $playerIndex: $error');
              return Container(
                width: markerSize,
                height: markerSize,
                decoration: BoxDecoration(
                  color: getPlayerColor(playerIndex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${playerIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Si hay más de 3 jugadores, mostramos un indicador
    if (hasMorePlayers) {
      markers.add(
        Positioned(
          bottom: 1,
          right: (maxPlayersPerCell * markerSize * overlapFactor) - 4,
          child: Container(
            width: markerSize * 0.8,
            height: markerSize * 0.8,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${playersInCell.length - maxPlayersPerCell}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return markers;
  }
}