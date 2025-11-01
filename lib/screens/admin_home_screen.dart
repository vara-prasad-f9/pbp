import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbp/screens/admin_game_dashboard.dart';
import 'package:pbp/services/room_service.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'game_setup_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_phone');
    await prefs.remove('is_admin');
    await prefs.remove('admin_room_id');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _cancelGame(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final roomId = prefs.getString('admin_room_id');
    if (roomId != null) {
      await RoomService().removeRoom(roomId);
      await prefs.remove('admin_room_id');
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game cancelled successfully')),
      );
    }
  }

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('user_phone');
    if (phoneNumber != null) {
      return User.findByPhone(phoneNumber);
    }
    return null;
  }

  Future<bool> _hasCreatedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final roomId = prefs.getString('admin_room_id');
    if (roomId == null) return false;
    
    final roomService = RoomService();
    final room = roomService.getRoom(roomId);
    if (room == null) {
      await prefs.remove('admin_room_id');
      return false;
    }
    return true;
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to PBP Game',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          final isAdmin = user?.isAdmin ?? false;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameSetupScreen(),
                      ),
                    );
                  },
                  child: const Text('Create New Game'),
                ),
                const SizedBox(height: 20),
                if (isAdmin)
                  ElevatedButton(
                    onPressed: () => _cancelGame(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel Current Game'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCreatedGame(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final hasActiveGame = snapshot.data ?? false;
        
        if (hasActiveGame) {
          return FutureBuilder<String?>(
            future: SharedPreferences.getInstance()
                .then((prefs) => prefs.getString('admin_room_id')),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Loading...')),
                  body: const Center(child: CircularProgressIndicator()),
                );
              }
              
              final roomId = snapshot.data;
              if (roomId == null) {
                return _buildHomeScreen(context);
              }
              
              return AdminGameDashboard(roomId: roomId);
            },
          );
        }
        
        return _buildHomeScreen(context);
      },
    );
  }
}