class Player {
  final String id;
  final String name;
  final String phone;
  final bool isHost;
  final bool isReady;
  final int score;
  final DateTime joinedAt;
  final String? roomId;
  final List<String> wins;          // e.g. ['first_jaldi']
  final String ticketNumber;        // NEW – e.g. "TKT-001"

  Player({
    required this.id,
    required this.name,
    this.phone = '',
    this.isHost = false,
    this.isReady = false,
    this.score = 0,
    DateTime? joinedAt,
    this.roomId,
    List<String>? wins,
    required this.ticketNumber,
  })  : joinedAt = joinedAt ?? DateTime.now(),
        wins = wins ?? [];

  Player copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isHost,
    bool? isReady,
    int? score,
    DateTime? joinedAt,
    String? roomId,
    List<String>? wins,
    String? ticketNumber,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      score: score ?? this.score,
      joinedAt: joinedAt ?? this.joinedAt,
      roomId: roomId ?? this.roomId,
      wins: wins ?? List.from(this.wins),
      ticketNumber: ticketNumber ?? this.ticketNumber,
    );
  }
}