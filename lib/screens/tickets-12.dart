// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../utils/name_mapper.dart';

class Tickets12 extends StatefulWidget {
  const Tickets12({super.key});

  @override
  State<Tickets12> createState() => _Tickets12State();
}

class _Tickets12State extends State<Tickets12> {
  List<List<int>> _generateTicketNumbers(int ticketId) {
    final List<List<int>> ticketNumbers = [];
    final Set<int> usedNumbers = {};
    for (int i = 0; i < 5; i++) {
      final List<int> row = [];
      for (int j = 0; j < 5; j++) {
        int number;
        do {
          number = 1 + (DateTime.now().millisecondsSinceEpoch % 90); // Simplified random for demo
        } while (usedNumbers.contains(number));
        usedNumbers.add(number);
        row.add(number);
      }
      ticketNumbers.add(row);
    }
    return ticketNumbers;
  }

  Widget _buildTicketCard(int ticketId) {
    final ticketNumbers = _generateTicketNumbers(ticketId);
    return Card(
      color: const Color.fromARGB(255, 206, 205, 205),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket #$ticketId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all( color: Colors.black,),
                 
              children: ticketNumbers.map<TableRow>((row) {
                return TableRow(
                  children: row.map<Widget>((number) {
                    return Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          NameMapper.getName(number),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 8,
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


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(12, (index) => _buildTicketCard(index + 1)),
        ),
      ),
    );
  }
}