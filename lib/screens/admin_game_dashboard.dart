// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'admin_home_screen.dart';

class AdminGameDashboard extends StatelessWidget {
  final String roomId;
  final int ticketCount;

  const AdminGameDashboard({
    Key? key,
    required this.roomId,
    required this.ticketCount,
  }) : super(key: key);

  Future<void> _endGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Game'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear any game-related data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_room_id');
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room $roomId - Admin Dashboard'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // End Game Button
            ElevatedButton.icon(
              onPressed: () => _endGame(context),
              icon: const Icon(Icons.stop_circle_outlined, size: 24),
              label: const Text(
                'End Game',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // View Game Details Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      roomId: roomId,
                      ticketCount: ticketCount,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 24),
              label: const Text(
                'View Game Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // View Players Button
            ElevatedButton.icon(
              onPressed: () {
          
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Players list will be shown here')),
                );
              },
              icon: const Icon(Icons.people, size: 24),
              label: const Text(
                'View Players',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
