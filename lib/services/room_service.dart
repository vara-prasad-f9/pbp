import 'package:pbp/models/room.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/player.dart';
import 'package:uuid/uuid.dart';

class RoomService {
  static final RoomService _instance = RoomService._internal();
  final Map<String, Room> _rooms = {};
  final _uuid = const Uuid();

  factory RoomService() {
    return _instance;
  }

  RoomService._internal();

  String generateRoomCode() {
    return _uuid.v4().substring(0, 6).toUpperCase();
  }

  Room createRoom({
    required String hostId,
    required String hostName,
    required String gameType,
    required int playerCount,
    required MoneyPrizes moneyPrizes,
  }) {
    final roomId = generateRoomCode();
    final room = Room(
      id: roomId,
      name: '$gameType Room',
      hostId: hostId,
      status: RoomStatus.waiting,
      createdAt: DateTime.now(),
      prizeDetails: PrizeDetails(
        gameType: gameType,
        playerCount: playerCount,
        moneyPrizes: moneyPrizes,
        itemPrizes: [],
      ),
      players: [
        Player(
          id: hostId,
          name: hostName,
          isHost: true,
          isReady: true,
        ),
      ],
    );

    _rooms[roomId] = room;
    return room;
  }

  Room? getRoom(String roomId) {
    return _rooms[roomId];
  }

  void addJoinRequest(String roomId, String userId, String userName) {
    final room = _rooms[roomId];
    if (room != null) {
      final request = JoinRequest(userId: userId, userName: userName);
      _rooms[roomId] = room.copyWith(
        joinRequests: [...room.joinRequests, request],
      );
    }
  }

  void handleJoinRequest(String roomId, String userId, bool isApproved) {
    final room = _rooms[roomId];
    if (room != null) {
      final updatedRequests = room.joinRequests.map((request) {
        if (request.userId == userId) {
          return request.copyWith(isApproved: isApproved);
        }
        return request;
      }).toList();

      _rooms[roomId] = room.copyWith(joinRequests: updatedRequests);

      if (isApproved) {
        final request = room.joinRequests.firstWhere((r) => r.userId == userId);
        final player = Player(
          id: userId,
          name: request.userName,
          isHost: false,
          isReady: false,
        );
        _rooms[roomId] = room.copyWith(
          players: [...room.players, player],
        );
      }
    }
  }

  bool isRoomFull(String roomId) {
    final room = _rooms[roomId];
    if (room == null) return true;
    return room.players.length >= room.prizeDetails.playerCount;
  }

  void removeRoom(String roomId) {
    _rooms.remove(roomId);
  }
}
