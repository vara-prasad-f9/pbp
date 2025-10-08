import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prize_details_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  void _showPlayerCountDialog(String gameType) {
    final playerCountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Number of Players'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: playerCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter number of players',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of players';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('NEXT'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final playerCount = int.parse(playerCountController.text);
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PrizeDetailsScreen(
                        gameType: gameType,
                        playerCount: playerCount,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Game Type',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGameTypeCard(
              context,
              icon: Icons.numbers,
              title: 'Classic Numbers',
              description: 'Traditional Tambola with numbers 1-90',
              onTap: () => _showPlayerCountDialog('Classic Numbers'),
            ),
            const SizedBox(height: 16),
            _buildGameTypeCard(
              context,
              icon: Icons.movie,
              title: 'Hero/Heroine Names',
              description: 'Play with Telugu movie star names',
              onTap: () => _showPlayerCountDialog('Hero/Heroine Names'),
            ),
            const SizedBox(height: 16),
            _buildGameTypeCard(
              context,
              icon: Icons.edit,
              title: 'Custom Words',
              description: 'Create your own custom word list',
              onTap: () {
              
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(25), // ~10% opacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
