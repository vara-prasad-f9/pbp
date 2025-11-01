// join_game_screen.dart
// ignore_for_file: file_names, sort_child_properties_last, unused_import, prefer_final_fields, deprecated_member_use, unnecessary_brace_in_string_interps

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pbp/screens/game_screen.dart';
import 'package:pbp/screens/tickets-12.dart';
import 'package:pbp/services/room_service.dart';
import 'package:uuid/uuid.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});
  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  int _selectedTickets = 1;
  int? _selectedRadioValue;
  List<int> _selectedCheckboxes = [];
  String? _errorMessage;

  @override
  void dispose() {
    _roomIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCustomDropdown() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            title: const Text('Select Tickets (Max 6)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<int>(
                    title: const Text('T1-to-T6'),
                    value: 1,
                    groupValue: _selectedRadioValue,
                    onChanged: (v) {
                      dialogSetState(() {
                        _selectedRadioValue = v;
                        _selectedCheckboxes.clear();
                        _selectedTickets = 6;
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('T7-to-T12'),
                    value: 2,
                    groupValue: _selectedRadioValue,
                    onChanged: (v) {
                      dialogSetState(() {
                        _selectedRadioValue = v;
                        _selectedCheckboxes.clear();
                        _selectedTickets = 6;
                      });
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Or pick individually:'),
                  ),
                  ...List.generate(12, (i) {
                    final n = i + 1;
                    return CheckboxListTile(
                      title: Text('T$n'),
                      value: _selectedCheckboxes.contains(n),
                      onChanged: (val) {
                        dialogSetState(() {
                          if (val == true) {
                            if (_selectedCheckboxes.length >= 6) return;
                            _selectedCheckboxes.add(n);
                            _selectedRadioValue = null;
                          } else {
                            _selectedCheckboxes.remove(n);
                          }
                          _selectedTickets = _selectedCheckboxes.length;
                          if (_selectedTickets == 0) _selectedTickets = 1;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> selectedTicketIds = [];
    if (_selectedCheckboxes.isNotEmpty) {
      selectedTicketIds = List.from(_selectedCheckboxes)..sort();
    } else if (_selectedRadioValue != null) {
      final start = _selectedRadioValue == 1 ? 1 : 7;
      selectedTicketIds = List.generate(6, (i) => start + i);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 70, 15, 70),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              // Room ID
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. RM72437572',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Ticket selector
              GestureDetector(
                onTap: _showCustomDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTicketIds.isNotEmpty
                            ? 'Selected ${_selectedTickets} ticket${_selectedTickets > 1 ? 's' : ''}'
                            : 'Select Tickets (Max 6)',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (selectedTicketIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 4,
                    children: [
                      for (int i = 0; i < selectedTicketIds.length; i += 2)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('T${selectedTicketIds[i]}',
                                style: const TextStyle(color: Colors.red, fontSize: 12)),
                            const SizedBox(width: 10),
                            if (i + 1 < selectedTicketIds.length)
                              Text('T${selectedTicketIds[i + 1]}',
                                  style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Ticket preview
              Expanded(child: Tickets12(selectedTicketIds: selectedTicketIds)),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _joinGame,
        tooltip: 'Join Game',
        child: const Icon(Icons.check),
      ),
    );
  }

  // -----------------------------------------------------------------
  // Join logic – adds player to in-memory room
  // -----------------------------------------------------------------
  void _joinGame() async {
    if (!_formKey.currentState!.validate()) return;

    final roomId = _roomIdController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Determine final ticket IDs
    List<int> ticketIds = [];
    if (_selectedCheckboxes.isNotEmpty) {
      ticketIds = List.from(_selectedCheckboxes)..sort();
    } else if (_selectedRadioValue != null) {
      final start = _selectedRadioValue == 1 ? 1 : 7;
      ticketIds = List.generate(6, (i) => start + i);
    } else {
      setState(() => _errorMessage = 'Select at least one ticket');
      return;
    }

    final userId = const Uuid().v4();

    final success = RoomService().addPlayer(
      roomId: roomId,
      userId: userId,
      name: name,
      phone: phone,
      ticketIds: ticketIds,
    );

    if (!success) {
      setState(() => _errorMessage = 'Room not found or full');
      return;
    }

    setState(() => _errorMessage = null);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          roomId: roomId,
          ticketIds: ticketIds,
          playerId: userId,
        ),
      ),
    );
  }
}