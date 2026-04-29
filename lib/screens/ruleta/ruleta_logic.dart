import 'package:flutter/material.dart';

class RuletaLogic {
  List<String> players;
  int currentPlayerIndex = 0;
  Map<String, Map<String, dynamic>?> apuestas = {};
  String fichaSeleccionada = '1';
  bool ruletaGirando = false;

  // Colores de la ruleta
  final Map<int, String> coloresRuleta = {
    0: 'verde',
    1: 'rojo', 2: 'negro', 3: 'rojo', 4: 'negro', 5: 'rojo', 6: 'negro', 7: 'rojo', 8: 'negro',
    9: 'rojo', 10: 'negro', 11: 'negro', 12: 'rojo', 13: 'negro', 14: 'rojo', 15: 'negro',
    16: 'rojo', 17: 'negro', 18: 'rojo', 19: 'rojo', 20: 'negro', 21: 'rojo', 22: 'negro',
    23: 'rojo', 24: 'negro', 25: 'rojo', 26: 'negro', 27: 'rojo', 28: 'negro', 29: 'negro',
    30: 'rojo', 31: 'negro', 32: 'rojo', 33: 'negro', 34: 'rojo', 35: 'negro', 36: 'rojo'
  };

  // Multiplicadores de apuestas
  final Map<String, int> multiplicadoresApuestas = {
    'rojo': 1, 'negro': 1, 'par': 1, 'impar': 1, 'falta': 1, 'pasa': 1,
    '1a12': 2, '2a12': 2, '3a12': 2, 'col1': 2, 'col2': 2, 'col3': 2,
    '0': 35, '1': 35, '2': 35, '3': 35, '4': 35, '5': 35, '6': 35, '7': 35, '8': 35, '9': 35,
    '10': 35, '11': 35, '12': 35, '13': 35, '14': 35, '15': 35, '16': 35, '17': 35, '18': 35,
    '19': 35, '20': 35, '21': 35, '22': 35, '23': 35, '24': 35, '25': 35, '26': 35, '27': 35,
    '28': 35, '29': 35, '30': 35, '31': 35, '32': 35, '33': 35, '34': 35, '35': 35, '36': 35
  };

  // Valores de las fichas
  final Map<String, int> valoresFichas = {
    '1': 1, '2': 2, '3': 3, 'hidalgo': 1
  };

  RuletaLogic(this.players) {
    // Inicializar apuestas
    for (var player in players) {
      apuestas[player] = null;
    }
  }

  String get currentPlayer => players[currentPlayerIndex];

  Color getColorNumero(int numero) {
    final color = coloresRuleta[numero];
    switch (color) {
      case 'rojo': return Colors.red;
      case 'negro': return Colors.black;
      case 'verde': return const Color(0xFF2E7D32);
      default: return Colors.black;
    }
  }

  Map<String, dynamic>? getApuestaActual() {
    return apuestas[currentPlayer];
  }

  bool jugadorActualHaApostado() {
    return apuestas[currentPlayer] != null;
  }

  bool todosHanApostado() {
    return players.every((player) => apuestas[player] != null);
  }

  bool esUltimoJugador() {
    return currentPlayerIndex == players.length - 1;
  }

  bool puedePasarSiguiente() {
    return jugadorActualHaApostado() && !esUltimoJugador() && !ruletaGirando;
  }

  void seleccionarFicha(String tipoFicha) {
    fichaSeleccionada = tipoFicha;
  }

  void agregarApuesta(String tipoApuesta) {
    if (ruletaGirando) return;
    
    apuestas[currentPlayer] = {
      'tipo': tipoApuesta,
      'ficha': fichaSeleccionada
    };
  }

  void siguienteJugador() {
    if (ruletaGirando || !jugadorActualHaApostado()) return;
    
    if (!esUltimoJugador()) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
  }

  Map<String, dynamic> girarRuleta() {
    final numeroGanador = _generarNumeroAleatorio();
    final colorGanador = coloresRuleta[numeroGanador]!;
    
    return {
      'numero': numeroGanador,
      'color': colorGanador
    };
  }

  int _generarNumeroAleatorio() {
    return DateTime.now().millisecond % 37;
  }

  bool apuestaGana(String tipoApuesta, int numeroGanador, String colorGanador) {
    switch(tipoApuesta) {
      case 'rojo': return colorGanador == 'rojo';
      case 'negro': return colorGanador == 'negro';
      case '0': return numeroGanador == 0;
      case 'par': return numeroGanador != 0 && numeroGanador % 2 == 0;
      case 'impar': return numeroGanador % 2 == 1;
      case 'falta': return numeroGanador >= 1 && numeroGanador <= 18;
      case 'pasa': return numeroGanador >= 19 && numeroGanador <= 36;
      case '1a12': return numeroGanador >= 1 && numeroGanador <= 12;
      case '2a12': return numeroGanador >= 13 && numeroGanador <= 24;
      case '3a12': return numeroGanador >= 25 && numeroGanador <= 36;
      case 'col1': return numeroGanador % 3 == 1;
      case 'col2': return numeroGanador % 3 == 2;
      case 'col3': return numeroGanador % 3 == 0 && numeroGanador != 0;
      default: return int.tryParse(tipoApuesta) == numeroGanador;
    }
  }

  List<Map<String, dynamic>> calcularResultados(int numeroGanador, String colorGanador) {
    List<Map<String, dynamic>> resultados = [];

    for (var player in players) {
      final apuestaPlayer = apuestas[player];
      int tragosTotales = 0;
      String detalle = '';
      String resultadoTexto = '';

      if (apuestaPlayer != null) {
        final tipo = apuestaPlayer['tipo'];
        final fichaTipo = apuestaPlayer['ficha'];
        
        final gano = apuestaGana(tipo, numeroGanador, colorGanador);
        final valorFicha = valoresFichas[fichaTipo]!;
        final esHidalgo = fichaTipo == 'hidalgo';
        final unidadTexto = esHidalgo ? 'hidalgo' : 'trago';
        final unidadTextoPlural = esHidalgo ? 'hidalgos' : 'tragos';
        
        if (gano) {
          final multiplicador = multiplicadoresApuestas[tipo] ?? 1;
          final tragosGanados = valorFicha * multiplicador;
          tragosTotales += tragosGanados;
          detalle = 'Apuesta: $tipo\n+$tragosGanados ${tragosGanados > 1 ? unidadTextoPlural : unidadTexto} ($valorFicha × $multiplicador)';
        } else {
          tragosTotales -= valorFicha;
          detalle = 'Apuesta: $tipo\n-$valorFicha ${valorFicha > 1 ? unidadTextoPlural : unidadTexto}';
        }
      } else {
        detalle = 'Sin apuesta';
      }
      
      if (tragosTotales > 0) {
        final esHidalgo = apuestaPlayer != null && apuestaPlayer['ficha'] == 'hidalgo';
        final unidadTexto = esHidalgo ? 'HIDALGO(S)' : 'TRAGO(S)';
        resultadoTexto = 'GANA $tragosTotales $unidadTexto PARA REPARTIR';
      } else if (tragosTotales < 0) {
        final esHidalgo = apuestaPlayer != null && apuestaPlayer['ficha'] == 'hidalgo';
        final unidadTexto = esHidalgo ? 'HIDALGO(S)' : 'TRAGO(S)';
        resultadoTexto = 'BEBE ${tragosTotales.abs()} $unidadTexto';
      } else {
        resultadoTexto = 'SIN CAMBIOS';
      }
      
      resultados.add({
        'jugador': player,
        'detalle': detalle,
        'resultado': resultadoTexto,
        'tragos': tragosTotales,
      });
    }

    return resultados;
  }

  void reiniciarParaSiguienteRonda() {
    ruletaGirando = false;
    
    // Reiniciar apuestas
    for (var player in players) {
      apuestas[player] = null;
    }
    
    // Reiniciar turno
    currentPlayerIndex = 0;
  }
}