import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp/screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'game_setup_screen.dart';
import 'join_game_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_phone');
    await prefs.remove('is_admin');
    await prefs.remove('hasCreatedGame');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Placeholder for canceling the game
  Future<void> _cancelGame(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasCreatedGame');
    // Add backend call or logic to cancel the game here
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game cancelled successfully')),
      );
    }
  }

  // Get current user from SharedPreferences
  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('user_phone');
    if (phoneNumber != null) {
      return User.findByPhone(phoneNumber);
    }
    return null;
  }

  // Check if user has created a game
  Future<bool> _hasCreatedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasCreatedGame') ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
        future: Future.wait([_getCurrentUser(), _hasCreatedGame()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data?[0] as User?;
          final hasCreatedGame = snapshot.data?[1] as bool? ?? false;
          final isAdmin = user?.isAdmin ?? false;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: hasCreatedGame
                  ? [
                      _buildActionButton(
                        context,
                        icon: Icons.info_outline,
                        label: 'View Game Details',
                        onTap: () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(
                                  roomId: 'created_game_id', // Placeholder; replace with actual ID
                                  ticketCount: 1,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(
                        context,
                        icon: Icons.cancel,
                        label: 'Cancel Game',
                        onTap: () => _cancelGame(context),
                      ),
                    ]
                  : [
                      _buildActionButton(
                        context,
                        icon: Icons.add_circle_outline,
                        label: 'Create Game',
                        onTap: () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GameSetupScreen()),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(
                        context,
                        icon: Icons.login,
                        label: 'Join Game',
                        isEnabled: !isAdmin,
                        disabledTooltip: 'Admin users cannot join games',
                        onTap: () {
                          if (context.mounted && !isAdmin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const JoinGameScreen()),
                            );
                          }
                        },
                      ),
                    ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
    String? disabledTooltip,
  }) {
    final button = SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onTap : null,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    if (!isEnabled && disabledTooltip != null) {
      return Tooltip(
        message: disabledTooltip,
        child: button,
      );
    }
    
    return button;
  }
}