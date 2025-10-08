import 'package:pbp/models/room.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/player.dart';
import 'package:uuid/uuid.dart';

class DummyRoomGenerator {
  static final _uuid = Uuid();
  
  static String generateRoomId() {
    // Generate a random 6-character alphanumeric room ID
    return _uuid.v4().substring(0, 6).toUpperCase();
  }

  static Room createDummyRoom({
    required String hostId,
    required String hostName,
    required String gameType,
    required int playerCount,
    required MoneyPrizes moneyPrizes,
    List<ItemPrize>? itemPrizes,
  }) {
    final now = DateTime.now();
    final roomId = generateRoomId();
    
    // Create host player
    final hostPlayer = Player(
      id: hostId,
      name: hostName,
      isHost: true,
      isReady: true,
      joinedAt: now,
    );

    return Room(
      id: roomId,
      name: '$gameType Room ${roomId.substring(0, 3)}',
      hostId: hostId,
      status: RoomStatus.waiting,
      createdAt: now,
      prizeDetails: PrizeDetails(
        gameType: gameType,
        playerCount: playerCount,
        moneyPrizes: moneyPrizes,
        itemPrizes: itemPrizes ?? [],
      ),
      players: [hostPlayer],
      joinRequests: [],
    );
  }

  // Get a list of dummy players (excluding host)
  static List<Player> getDummyPlayers(int count, {String? roomId}) {
    final players = <Player>[];
    final now = DateTime.now();
    
    for (var i = 0; i < count; i++) {
      players.add(Player(
        id: 'player_${_uuid.v4()}',
        name: 'Player ${i + 1}',
        isHost: false,
        isReady: i % 2 == 0, // Every other player is ready
        joinedAt: now.add(Duration(minutes: i)),
        roomId: roomId,
      ));
    }
    
    return players;
  }

  // Get a dummy room with players
  static Room getDummyRoomWithPlayers({
    required String hostId,
    required String hostName,
    required String gameType,
    required int playerCount,
    required MoneyPrizes moneyPrizes,
    List<ItemPrize>? itemPrizes,
  }) {
    final room = createDummyRoom(
      hostId: hostId,
      hostName: hostName,
      gameType: gameType,
      playerCount: playerCount,
      moneyPrizes: moneyPrizes,
      itemPrizes: itemPrizes,
    );

    // Add dummy players (excluding host)
    final dummyPlayers = getDummyPlayers(playerCount - 1, roomId: room.id);
    room.players.addAll(dummyPlayers);

    return room;
  }
}
