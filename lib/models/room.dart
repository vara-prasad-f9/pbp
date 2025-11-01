import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/player.dart';

enum RoomStatus { waiting, inProgress, completed }

class Room {
  final String id;
  final String name;
  final String hostId;
  final RoomStatus status;
  final DateTime createdAt;
  final PrizeDetails prizeDetails;
  final List<Player> players;
  final List<JoinRequest> joinRequests;

  Room({
    required this.id,
    required this.name,
    required this.hostId,
    required this.status,
    required this.createdAt,
    required this.prizeDetails,
    List<Player>? players,
    List<JoinRequest>? joinRequests,
  })  : players = players ?? [],
        joinRequests = joinRequests ?? [];

  Room copyWith({
    String? id,
    String? name,
    String? hostId,
    RoomStatus? status,
    DateTime? createdAt,
    PrizeDetails? prizeDetails,
    List<Player>? players,
    List<JoinRequest>? joinRequests,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      prizeDetails: prizeDetails ?? this.prizeDetails,
      players: players ?? this.players,
      joinRequests: joinRequests ?? this.joinRequests,
    );
  }
}

class JoinRequest {
  final String userId;
  final String userName;
  final DateTime requestedAt;
  final bool isApproved;

  JoinRequest({
    required this.userId,
    required this.userName,
    DateTime? requestedAt,
    this.isApproved = false,
  }) : requestedAt = requestedAt ?? DateTime.now();

  JoinRequest copyWith({
    String? userId,
    String? userName,
    DateTime? requestedAt,
    bool? isApproved,
  }) {
    return JoinRequest(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      requestedAt: requestedAt ?? this.requestedAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}