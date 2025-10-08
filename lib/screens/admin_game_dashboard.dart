// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'admin_home_screen.dart';

class AdminGameDashboard extends StatelessWidget {
  final String roomId;

  const AdminGameDashboard({
    Key? key,
    required this.roomId,
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
                // Example: Pass a list of ticket IDs (e.g., dynamically determined or default)
                List<int> ticketIds = [1, 2, 3, 4, 5, 6]; // Default to T1-T6; replace with actual selection logic
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      roomId: roomId,
                      ticketIds: ticketIds,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text(
                'Start Game',
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