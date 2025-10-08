class GameTicket {
  final int id;
  final String playerName;
  final List<List<int>> numbers;
  final bool isClaimed;
  final DateTime purchaseTime;

  GameTicket({
    required this.id,
    required this.playerName,
    required this.numbers,
    this.isClaimed = false,
    required this.purchaseTime,
  });
}

// Dummy data generator for game tickets
List<GameTicket> generateDummyTickets(String roomId, int ticketCount) {
  final List<GameTicket> tickets = [];
  final now = DateTime.now();
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  for (int i = 0; i < ticketCount; i++) {
    // Generate a unique ticket ID using timestamp and index
    final ticketId = timestamp + i;
    final playerName = 'Player ${i + 1}';
    
    // Generate numbers for the ticket (5x5 grid with numbers 1-90)
    final numbers = List.generate(5, (row) => 
      List.generate(5, (col) => 1 + (i * 25 + row * 5 + col) % 90)
    );
    
    tickets.add(GameTicket(
      id: ticketId,
      playerName: playerName,
      numbers: numbers,
      purchaseTime: now,
    ));
  }
  
  return tickets;
}
