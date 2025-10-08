// ignore_for_file: file_names, unused_field, unused_element, sort_child_properties_last, prefer_final_fields, duplicate_ignore, deprecated_member_use

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
  bool _showTicketGrid = false;
  List<GameTicket> _tickets = [];
  int? _selectedRadioValue; // For radio button selection
  List<int> _selectedCheckboxes = []; // For checkbox selections

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _generateTickets() {
    _tickets = List.generate(_selectedTickets, (index) => GameTicket(
      id: index + 1,
      playerName: 'Player ${index + 1}',
      numbers: _generateTicketNumbers(),
      isClaimed: false,
      purchaseTime: DateTime.now(),
    ));
    setState(() {
      _showTicketGrid = true;
    });
  }

  List<List<int>> _generateTicketNumbers() {
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

  Widget _buildTicketCard(GameTicket ticket) {
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
                    return Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          NameMapper.getName(number),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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

  void _showCustomDropdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Tickets'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<int>(
                      title: const Text('T1-to-T6'),
                      value: 6,
                      groupValue: _selectedRadioValue,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedRadioValue = value;
                          _selectedCheckboxes.clear();
                          _selectedTickets = value ?? 1;
                        });
                        // Update parent state before closing
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    RadioListTile<int>(
                      title: const Text('T6-to-T12'),
                      value: 12,
                      groupValue: _selectedRadioValue,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedRadioValue = value;
                          _selectedCheckboxes.clear();
                          _selectedTickets = value ?? 1;
                        });
                        // Update parent state before closing
                        setState(() {});
                        Navigator.pop(context);
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
                          setState(() {
                            if (value == true) {
                              _selectedCheckboxes.add(ticketNum);
                              _selectedRadioValue = null; // Deselect radio on checkbox selection
                            } else {
                              _selectedCheckboxes.remove(ticketNum);
                            }
                            _selectedTickets = _selectedCheckboxes.length > 6 ? 6 : _selectedCheckboxes.length;
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
                    // Update parent state when closing dialog
                    setState(() {});
                    Navigator.pop(context);
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
                        _selectedCheckboxes.isNotEmpty || _selectedRadioValue != null
                            ? 'Your selected $_selectedTickets so on tickets...'
                            : 'Select Tickets (Max 6):',
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (_selectedCheckboxes.isNotEmpty || _selectedRadioValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 20.0, // Space between pairs
                    runSpacing: 4.0, // Space between rows
                    children: [
                      for (int i = 0; i < (_selectedCheckboxes.isNotEmpty ? _selectedCheckboxes.length : _selectedRadioValue ?? 0); i += 2)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'T${_selectedCheckboxes.isNotEmpty ? _selectedCheckboxes[i] : i + 1}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            const SizedBox(width: 10), // Space between T1 and T2
                            if (i + 1 < (_selectedCheckboxes.isNotEmpty ? _selectedCheckboxes.length : _selectedRadioValue ?? 0))
                              Text(
                                'T${_selectedCheckboxes.isNotEmpty ? _selectedCheckboxes[i + 1] : i + 2}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Tickets12(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Check if at least one ticket is selected
            if (_selectedTickets < 1 || (_selectedCheckboxes.isEmpty && _selectedRadioValue == null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select at least one ticket.')),
              );
              return;
            }
            _generateTickets();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(
                  roomId: _roomIdController.text.trim(),
                  ticketCount: _selectedTickets,
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