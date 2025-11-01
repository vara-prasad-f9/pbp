// admin_game_dashboard.dart
// ignore_for_file: use_build_context_synchronously, unused_import, use_super_parameters, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:pbp/services/room_service.dart';
import 'package:pbp/models/player.dart';
import 'login_screen.dart';

class AdminGameDashboard extends StatelessWidget {
  final String roomId;

  const AdminGameDashboard({Key? key, required this.roomId}) : super(key: key);

  // -----------------------------------------------------------------
  // LOGOUT / CANCEL
  // -----------------------------------------------------------------
  Future<void> _handleLogout(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (ctx.mounted) {
      Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _cancelGame(BuildContext ctx) async {
    RoomService().removeRoom(roomId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_room_id');
    await prefs.remove('auth_token');
    if (ctx.mounted) {
      Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  // -----------------------------------------------------------------
  // Rebuild when the room changes (polling – cheap for MVP)
  // -----------------------------------------------------------------
  ValueNotifier<int> _roomNotifier(String rid) {
    final n = ValueNotifier(0);
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (RoomService().getRoom(rid) == null) {
        timer.cancel();               // <-- fixed: named parameter
      } else {
        n.value++;
      }
    });
    return n;
  }

  // -----------------------------------------------------------------
  // UI
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _roomNotifier(roomId),
      builder: (context, _, __) {
        final room = RoomService().getRoom(roomId);
        final players = room?.players.where((p) => !p.isHost).toList() ?? [];

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Game Dashboard'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _handleLogout(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ------------------- Room Code Card -------------------
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Room Code',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                roomId,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () {
                                  FlutterClipboard.copy(roomId).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Room code copied!')),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  Share.share('Join my Thombola game! Room Code: $roomId');
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.people),
                                label: const Text('Players'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {}, // table already visible
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------- Players Table -------------------
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Players List',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    '${players.length} Player${players.length == 1 ? '' : 's'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.blue.shade50,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: players.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No players yet.\nShare the room code to start!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 20,
                                      headingRowColor: WidgetStateColor.resolveWith(
                                          (states) => Colors.blue.shade50),
                                      columns: const [
                                        DataColumn(
                                            label: Text('Ticket',
                                                style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Name',
                                                style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Phone',
                                                style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Win',
                                                style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: players.map((p) {
                                        final wins = p.wins.length;
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(p.ticketNumber,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600))),
                                            DataCell(Text(p.name)),
                                            DataCell(Text(p.phone.isEmpty ? '-' : p.phone)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: wins > 0
                                                      ? Colors.green.shade100
                                                      : Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  wins.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: wins > 0
                                                        ? Colors.green.shade700
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------- Game Controls -------------------
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow, size: 30),
                          label: const Text(
                            'START GAME',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Game started! (mock)')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Cancel Game'),
                              content: const Text('This will end the game for all players.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
                                TextButton(
                                  onPressed: () => _cancelGame(context),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('YES, CANCEL'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'CANCEL GAME',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}