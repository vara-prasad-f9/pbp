// ignore_for_file: prefer_final_fields, use_super_parameters, library_private_types_in_public_api, deprecated_member_use, duplicate_ignore

// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_ticket.dart';
import '../utils/name_mapper.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final int ticketCount;

  const GameScreen({
    Key? key,
    required this.roomId,
    required this.ticketCount,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> calledNumbers = [];
  List<GameTicket> tickets = [];
  bool isNumberCalling = false;
  bool useHeroNames = true;
  Timer? _numberCallTimer;
  final Random _random = Random();
  Set<int> markedNumbers = {};

  @override
  void initState() {
    super.initState();
    tickets = List.generate(widget.ticketCount, (index) => GameTicket(
      id: index + 1,
      playerName: 'Player ${index + 1}',
      numbers: _generateTicketNumbers(),
      isClaimed: false,
      purchaseTime: DateTime.now(),
    ));
  }

  List<List<int>> _generateTicketNumbers() {
    final List<List<int>> ticketNumbers = [];
    final Set<int> usedNumbers = {};
    for (int i = 0; i < 5; i++) {
      final List<int> row = [];
      for (int j = 0; j < 5; j++) {
        int number;
        do {
          number = 1 + _random.nextInt(90);
        } while (usedNumbers.contains(number));
        usedNumbers.add(number);
        row.add(number);
      }
      ticketNumbers.add(row);
    }
    return ticketNumbers;
  }

  @override
  void dispose() {
    _numberCallTimer?.cancel();
    super.dispose();
  }

  Widget _buildNumberChip(int number, {int? serialNumber}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 1, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: serialNumber != null
          ? Text(
              '$serialNumber. ${NameMapper.getName(number)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : Text(
              NameMapper.getName(number),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }

  Widget buildTicketCard(GameTicket ticket) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket #${ticket.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: ticket.numbers.map<TableRow>((row) {
                return TableRow(
                  children: row.map<Widget>((number) {
                    final isMarked = markedNumbers.contains(number);
                    final isCalled = calledNumbers.contains(number);

                    return GestureDetector(
                      onTap: () {
                        if (isCalled) {
                          setState(() {
                            if (isMarked) {
                              markedNumbers.remove(number);
                            } else {
                              markedNumbers.add(number);
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Number ${NameMapper.getName(number)} is not yet called!",
                                textAlign: TextAlign.center,
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: isMarked ? Colors.green[300] : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            NameMapper.getName(number),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMarked ? Colors.white : Colors.black87,
                              fontSize: 12, // Increased for better readability
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllNumbers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Called Numbers'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: calledNumbers.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final number = entry.value;
              return _buildNumberChip(number, serialNumber: index);
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startOrPauseCalling() {
    setState(() {
      isNumberCalling = !isNumberCalling;
      if (isNumberCalling) {
        _callNextNumber();
      } else {
        _numberCallTimer?.cancel();
      }
    });
  }

  void _callNextNumber() {
    if (calledNumbers.length >= 90) return;

    int nextNumber;
    do {
      nextNumber = 1 + _random.nextInt(90);
    } while (calledNumbers.contains(nextNumber));

    setState(() {
      calledNumbers.add(nextNumber);
      // Sort only if needed for display, not every call
    });

    if (isNumberCalling && calledNumbers.length < 90) {
      _numberCallTimer = Timer(const Duration(seconds: 15), _callNextNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentNumber = calledNumbers.isNotEmpty ? calledNumbers.last : null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              '${widget.roomId} • ${widget.ticketCount} ${widget.ticketCount == 1 ? 'Ticket' : 'Tickets'}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        actions: [
          if (calledNumbers.isNotEmpty) ...[
            Text("(${calledNumbers.length}/90)",
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _showAllNumbers,
              child: const Text('View All', style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startOrPauseCalling,
        tooltip: isNumberCalling ? 'Pause' : 'Start',
        child: Icon(isNumberCalling ? Icons.pause : Icons.play_arrow),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recentNumber != null
                  ? [
                      _buildNumberChip(recentNumber, serialNumber: calledNumbers.length)
                    ]
                  : [],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) => buildTicketCard(tickets[index]),
            ),
          ),
        ],
      ),
    );
  }
}
// ignore_for_file: file_names