class GameMode {
  final String id;
  final String name;
  final String icon;
  final int minPlayers;
  final bool enabled;

  const GameMode({
    required this.id,
    required this.name,
    required this.icon,
    required this.minPlayers,
    this.enabled = true,
  });
}