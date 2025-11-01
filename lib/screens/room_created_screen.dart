// room_created_screen.dart
// ignore_for_file: use_build_context_synchronously, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:pbp/screens/admin_game_dashboard.dart';
import 'package:pbp/services/room_service.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/models/room.dart';

class RoomCreatedScreen extends StatelessWidget {
  final String hostId;
  final String hostName;
  final String gameType;
  final int playerCount;
  final MoneyPrizes moneyPrizes;

  const RoomCreatedScreen({
    super.key,
    required this.hostId,
    required this.hostName,
    required this.gameType,
    required this.playerCount,
    required this.moneyPrizes,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Room>(
      future: RoomService().createRoom(
        hostId: hostId,
        hostName: hostName,
        gameType: gameType,
        playerCount: playerCount,
        moneyPrizes: moneyPrizes,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error creating room: ${snapshot.error}')),
          );
        }

        final room = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Lobby'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share('Join my Tambola game! Room Code: ${room.id}'),
                tooltip: 'Share Room Code',
              ),
              IconButton(
                icon: const Icon(Icons.content_copy),
                onPressed: () {
                  FlutterClipboard.copy(room.id).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room code copied!')),
                    );
                  });
                },
                tooltip: 'Copy Room Code',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Room Code',
                          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          room.id,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share this code with players to join',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Players (1/$playerCount)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'Waiting for players...\nShare the code: ${room.id}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminGameDashboard(roomId: room.id),
                ),
              );
            },
            backgroundColor: Colors.green,
            label: const Text('OPEN DASHBOARD'),
            icon: const Icon(Icons.dashboard),
          ),
        );
      },
    );
  }
}