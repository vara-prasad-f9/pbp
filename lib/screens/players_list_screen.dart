// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayersListScreen extends StatelessWidget {
  final List<Player> players;
  final Function(Player)? onAccept;
  final Function(Player)? onRemove;
  final Function(Player)? onView;

  const PlayersListScreen({
    Key? key,
    required this.players,
    this.onAccept,
    this.onRemove,
    this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players List'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: players.map((player) {
            return DataRow(
              cells: [
                DataCell(Text(player.name)),
                DataCell(Text(player.id)), // Using ID as phone number for now
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: player.isReady ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(player.isReady ? 'Active' : 'Pending'),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      if (onAccept != null && !player.isReady)
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => onAccept!(player),
                          tooltip: 'Accept',
                        ),
                      if (onView != null)
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => onView!(player),
                          tooltip: 'View Details',
                        ),
                      if (onRemove != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemove!(player),
                          tooltip: 'Remove',
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
