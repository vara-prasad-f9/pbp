class Player {
  final String id;
  final String name;
  final bool isHost;
  final bool isReady;
  final int score;
  final DateTime joinedAt;
  final String? roomId;

  Player({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
    this.score = 0,
    DateTime? joinedAt,
    this.roomId,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Player copyWith({
    String? id,
    String? name,
    bool? isHost,
    bool? isReady,
    int? score,
    DateTime? joinedAt,
    String? roomId,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      score: score ?? this.score,
      joinedAt: joinedAt ?? this.joinedAt,
      roomId: roomId ?? this.roomId,
    );
  }
}
