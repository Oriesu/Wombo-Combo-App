class CaballosLogic {
  final List<Carta> _deck = [];
  final List<Carta> _discardPile = [];
  final List<Carta> _trackCards = [];
  final Map<String, Horse> _horses = {};
  final List<bool> _flippedStages = [];
  
  int get deckCount => _deck.length;
  int get flippedCount => _flippedStages.where((flipped) => flipped).length;
  List<Carta> get trackCards => _trackCards;
  Map<String, Horse> get horses => _horses;
  List<bool> get flippedStages => _flippedStages;
  List<Carta> get discardPile => _discardPile;
  
  static const int totalStages = 5;
  static const List<String> suits = ['oros', 'copas', 'espadas', 'bastos'];
  static const List<String> values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

  void initializeGame() {
    _initializeDeck();
    _initializeHorses();
    _initializeTrack();
    _flippedStages.clear();
    for (int i = 0; i < totalStages; i++) {
      _flippedStages.add(false);
    }
  }

  void _initializeDeck() {
    _deck.clear();
    _discardPile.clear();
    _trackCards.clear();
    
    // Crear mazo completo
    for (final suit in suits) {
      for (final value in values) {
        _deck.add(Carta(suit: suit, value: value));
      }
    }
    
    _shuffleDeck();
  }

  void _initializeHorses() {
    _horses.clear();
    
    // Encontrar las cartas de caballo para cada palo
    final horseCards = _deck.where((carta) => carta.value == '11').toList();
    
    // Remover las cartas de caballo del mazo principal
    _deck.removeWhere((carta) => carta.value == '11');
    
    for (final suit in suits) {
      final horseCard = horseCards.firstWhere((carta) => carta.suit == suit);
      _horses[suit] = Horse(
        position: 0,
        finished: false,
        carta: horseCard,
      );
    }
  }

  void _initializeTrack() {
    _trackCards.clear();
    for (int i = 0; i < totalStages; i++) {
      if (_deck.isNotEmpty) {
        _trackCards.add(_deck.removeLast());
      }
    }
  }

  void _shuffleDeck() {
    _deck.shuffle();
  }

  void drawCard() {
    if (_deck.isEmpty) return;
    
    final drawnCard = _deck.removeLast();
    _discardPile.add(drawnCard);
    _moveHorse(drawnCard.suit);
    _checkStageFlip();
  }

  void _moveHorse(String suit) {
    final horse = _horses[suit];
    if (!horse!.finished && horse.position < totalStages + 1) {
      horse.position++;
      if (horse.position == totalStages + 1) {
        horse.finished = true;
      }
    }
  }

  void _checkStageFlip() {
    for (int i = 0; i < totalStages; i++) {
      if (_flippedStages[i]) continue;
      
      bool allHorsesArrived = true;
      for (final horse in _horses.values) {
        if (horse.position < i + 1 && !horse.finished) {
          allHorsesArrived = false;
          break;
        }
      }
      
      if (allHorsesArrived) {
        _flipStage(i);
        break;
      }
    }
  }

  void _flipStage(int stageIndex) {
    _flippedStages[stageIndex] = true;
    final flippedCard = _trackCards[stageIndex];
    final horse = _horses[flippedCard.suit];
    if (!horse!.finished && horse.position > 0) {
      horse.position--;
    }
  }

  bool get canDrawCard => _deck.isNotEmpty;
  
  bool get isGameFinished {
    final finishedHorses = _horses.values.where((horse) => horse.finished).length;
    return finishedHorses > 0 || (_deck.isEmpty && !_canAnyHorseMove);
  }
  
  bool get _canAnyHorseMove {
    return _horses.values.any((horse) => !horse.finished && horse.position < totalStages + 1);
  }

  void resetGame() {
    initializeGame();
  }
}

class Carta {
  final String suit;
  final String value;
  
  Carta({required this.suit, required this.value});
  
  String get imagePath => 'lib/screens/caballos/barajaEsp/${value}${suit}.png';
}

class Horse {
  int position;
  bool finished;
  Carta carta;
  
  Horse({
    required this.position,
    required this.finished,
    required this.carta,
  });
  
  String get suitName {
    final suitNames = {
      'oros': 'Oros',
      'copas': 'Copas',
      'espadas': 'Espadas',
      'bastos': 'Bastos'
    };
    return suitNames[carta.suit]!;
  }
  
  Carta get card => carta;
}