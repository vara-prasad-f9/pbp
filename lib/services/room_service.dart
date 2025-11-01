import 'package:pbp/models/room.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/player.dart';
import 'package:uuid/uuid.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RoomService {
  // -------------------------------------------------
  // Singleton
  // -------------------------------------------------
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  final Map<String, Room> _rooms = {};
  final _uuid = const Uuid();
  static const String _roomIdKey = 'admin_room_id';

  Future<void> persistRoomId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomIdKey, roomId);
  }

  Future<String?> getPersistedRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roomIdKey);
  }

  Future<void> clearPersistedRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roomIdKey);
  }
  
  // Removed duplicate removeRoom method

  // -------------------------------------------------
  // Public API
  // -------------------------------------------------
  String generateRoomCode() {
    return _uuid.v4().substring(0, 6).toUpperCase();
  }

  Future<Room> createRoom({
    required String hostId,
    required String hostName,
    required String gameType,
    required int playerCount,
    required MoneyPrizes moneyPrizes,
  }) async {
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
          ticketNumber: 'HOST',   // host has no ticket
        ),
      ],
    );

    _rooms[roomId] = room;
    await persistRoomId(roomId);
    return room;
  }

  Room? getRoom(String roomId) => _rooms[roomId];

  // -------------------------------------------------
  // Player joins directly (no approval flow for MVP)
  // -------------------------------------------------
  bool addPlayer({
    required String roomId,
    required String userId,
    required String name,
    required String phone,
    required List<int> ticketIds,   // e.g. [1,3,5]
  }) {
    final room = _rooms[roomId];
    if (room == null) return false;
    if (room.players.length >= room.prizeDetails.playerCount) return false;

    // Generate a single ticket number for the UI (you can change logic)
    final ticketNumber = 'TKT-${ticketIds.map((e) => e.toString().padLeft(2, '0')).join('-')}';

    final player = Player(
      id: userId,
      name: name,
      phone: phone,
      isHost: false,
      isReady: true,
      ticketNumber: ticketNumber,
    );

    _rooms[roomId] = room.copyWith(players: [...room.players, player]);
    return true;
  }

  // -------------------------------------------------
  // Optional: increment wins
  // -------------------------------------------------
  void incrementWin(String roomId, String playerId, String winType) {
    final room = _rooms[roomId];
    if (room == null) return;
    final idx = room.players.indexWhere((p) => p.id == playerId);
    if (idx == -1) return;

    final p = room.players[idx];
    final newWins = [...p.wins, winType];
    final updated = p.copyWith(wins: newWins);
    final newList = [...room.players]..[idx] = updated;
    _rooms[roomId] = room.copyWith(players: newList);
  }

  Future<bool> removeRoom(String roomId) async {
    final removed = _rooms.remove(roomId) != null;
    if (removed) {
      await clearPersistedRoomId();
    }
    return removed;
  }
}