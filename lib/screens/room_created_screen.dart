// ignore_for_file: unused_field, await_only_futures, use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pbp/models/room.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/player.dart';
import 'package:pbp/services/room_service.dart';
import 'package:pbp/dummy-data/room_data.dart';
import 'package:clipboard/clipboard.dart';

class RoomCreatedScreen extends StatefulWidget {
  final String roomId;
  final String gameType;
  final int playerCount;
  final MoneyPrizes moneyPrizes;
  final Room? initialRoom;

  const RoomCreatedScreen({
    super.key,
    required this.roomId,
    required this.gameType,
    required this.playerCount,
    required this.moneyPrizes,
    this.initialRoom,
  });

  @override
  State<RoomCreatedScreen> createState() => _RoomCreatedScreenState();
  
  // Helper method to create a copy with a new room
  // Create a copy with a new room
  RoomCreatedScreen copyWithRoom(Room room) {
    return RoomCreatedScreen(
      key: key,
      roomId: room.id,
      gameType: gameType,
      playerCount: playerCount,
      moneyPrizes: moneyPrizes,
      initialRoom: room,
    );
  }
}

class _RoomCreatedScreenState extends State<RoomCreatedScreen> {
  final _roomService = RoomService();
  late Room _room = Room(
    id: '',
    name: 'Loading...',
    hostId: '',
    status: RoomStatus.waiting,
    createdAt: DateTime.now(),
    prizeDetails: PrizeDetails(
      gameType: widget.gameType,
      playerCount: widget.playerCount,
      moneyPrizes: widget.moneyPrizes,
      itemPrizes: [],
    ),
    players: [],
    joinRequests: [],
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  Future<void> _initializeRoom() async {
    if (!mounted) return;
    
    // In a real app, you would get the current user from your auth service
    final currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Host',
      phone: '',
      isAdmin: true,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a dummy room with players
      final newRoom = DummyRoomGenerator.getDummyRoomWithPlayers(
        hostId: currentUser.id,
        hostName: currentUser.name,
        gameType: widget.gameType,
        playerCount: widget.playerCount,
        moneyPrizes: widget.moneyPrizes,
      );
      
      if (mounted) {
        setState(() {
          _room = newRoom;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating room: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareRoomCode() async {
    if (!mounted) return;
    
    final box = context.findRenderObject() as RenderBox?;
    final sharePosition = box != null 
        ? Rect.fromPoints(
            box.localToGlobal(Offset.zero),
            box.localToGlobal(Offset(box.size.width, box.size.height)),
          )
        : null;
    
    await Share.share(
      'Join my Tambola game! Room Code: ${widget.roomId}\n\nDownload the app to join: [APP_LINK]',
      sharePositionOrigin: sharePosition,
    );
  }

  void _copyRoomCode() {
    FlutterClipboard.copy(widget.roomId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room code copied to clipboard')),
      );
    });
  }

  void _startGame() {
    if (!mounted) return;

    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting the game...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Created'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRoomCode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Your Room Code',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.roomId,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: _copyRoomCode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Share this code with your friends to join the game',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Players',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<Room?>(
                      stream: Stream.periodic(
                        const Duration(seconds: 2),
                        (_) => _roomService.getRoom(widget.roomId),
                      ),
                      builder: (context, snapshot) {
                        final room = snapshot.data;
                        if (room == null) {
                          return const Center(child: Text('Room not found'));
                        }

                        return ListView.builder(
                          itemCount: room.players.length,
                          itemBuilder: (context, index) {
                            final player = room.players[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(player.name[0].toUpperCase()),
                              ),
                              title: Text(player.name),
                              subtitle: Text(player.isHost ? 'Host' : 'Player'),
                              trailing: player.isReady
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.schedule, color: Colors.orange),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy User class - replace with your actual User model
class User {
  final String id;
  final String name;
  final String phone;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.isAdmin,
  });
}
