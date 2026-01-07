class Player {
  final String name;
  final int position;
  final String color;

  Player({
    required this.name,
    this.position = 1,
    required this.color,
  });

  // Convertir a Map para shared_preferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'color': color,
    };
  }

  // Crear desde Map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'],
      position: map['position'],
      color: map['color'],
    );
  }
}