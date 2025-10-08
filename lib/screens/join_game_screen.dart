// ignore_for_file: file_names, unused_field, unused_element, sort_child_properties_last, prefer_final_fields, duplicate_ignore, deprecated_member_use, unused_import, unnecessary_brace_in_string_interps

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pbp/screens/game_screen.dart';
import 'package:pbp/screens/tickets-12.dart';
import '../models/game_ticket.dart';
import '../utils/name_mapper.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  int _selectedTickets = 1;
  int? _selectedRadioValue; // For radio button selection (1 for T1-T6, 2 for T7-T12)
  List<int> _selectedCheckboxes = []; // For checkbox selections

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  List<List<int>> _generateTicketNumbers(int seed) {
    final random = Random(seed);
    final List<List<int>> ticketNumbers = [];
    final Set<int> usedNumbers = {};
    for (int i = 0; i < 5; i++) {
      final List<int> row = [];
      for (int j = 0; j < 5; j++) {
        int number;
        do {
          number = 1 + random.nextInt(90);
        } while (usedNumbers.contains(number));
        usedNumbers.add(number);
        row.add(number);
      }
      ticketNumbers.add(row);
    }
    return ticketNumbers;
  }

  void _showCustomDropdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Select Tickets'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<int>(
                      title: const Text('T1-to-T6'),
                      value: 1,
                      groupValue: _selectedRadioValue,
                      onChanged: (int? value) {
                        dialogSetState(() {
                          _selectedRadioValue = value;
                          _selectedCheckboxes.clear();
                          _selectedTickets = 6;
                        });
                        Navigator.pop(context);
                        setState(() {}); // Update parent state
                      },
                    ),
                    RadioListTile<int>(
                      title: const Text('T7-to-T12'),
                      value: 2,
                      groupValue: _selectedRadioValue,
                      onChanged: (int? value) {
                        dialogSetState(() {
                          _selectedRadioValue = value;
                          _selectedCheckboxes.clear();
                          _selectedTickets = 6;
                        });
                        Navigator.pop(context);
                        setState(() {}); // Update parent state
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Or select individual tickets:'),
                    ),
                    ...List.generate(12, (index) {
                      int ticketNum = index + 1;
                      return CheckboxListTile(
                        title: Text('T$ticketNum'),
                        value: _selectedCheckboxes.contains(ticketNum),
                        onChanged: (bool? value) {
                          dialogSetState(() {
                            if (value == true) {
                              if (_selectedCheckboxes.length >= 6) return; // Cap at 6
                              _selectedCheckboxes.add(ticketNum);
                              _selectedRadioValue = null; // Deselect radio on checkbox selection
                            } else {
                              _selectedCheckboxes.remove(ticketNum);
                            }
                            _selectedTickets = _selectedCheckboxes.length;
                            if (_selectedTickets == 0) _selectedTickets = 1;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {}); // Update parent state when closing
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter Room ID',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
                            ? 'Your selected ${_selectedTickets} tickets...'
                            : 'Select Tickets (Max 6):',
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
                    spacing: 20.0, // Space between pairs
                    runSpacing: 4.0, // Space between rows
                    children: [
                      for (int i = 0; i < selectedTicketIds.length; i += 2)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'T${selectedTicketIds[i]}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            const SizedBox(width: 10), // Space between T1 and T2
                            if (i + 1 < selectedTicketIds.length)
                              Text(
                                'T${selectedTicketIds[i + 1]}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Tickets12(selectedTicketIds: selectedTicketIds),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            List<int> selectedTicketIds = [];
            if (_selectedCheckboxes.isNotEmpty) {
              selectedTicketIds = List.from(_selectedCheckboxes)..sort();
            } else if (_selectedRadioValue != null) {
              final start = _selectedRadioValue == 1 ? 1 : 7;
              selectedTicketIds = List.generate(6, (i) => start + i);
            }

            if (selectedTicketIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select at least one ticket.')),
              );
              return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(
                  roomId: _roomIdController.text.trim(),
                  ticketIds: selectedTicketIds,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
        tooltip: 'Submit',
      ),
    );
  }
}