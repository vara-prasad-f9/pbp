// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:pbp/models/prize_details.dart';
import 'package:pbp/screens/room_created_screen.dart';

class PrizeDetailsScreen extends StatefulWidget {
  final String gameType;
  final int playerCount;

  const PrizeDetailsScreen({
    super.key,
    required this.gameType,
    required this.playerCount,
  });

  @override
  State<PrizeDetailsScreen> createState() => _PrizeDetailsScreenState();
}

class _PrizeDetailsScreenState extends State<PrizeDetailsScreen> {
  int _selectedTab = 0; // 0 for Money, 1 for Items
  final _formKey = GlobalKey<FormState>();
  late MoneyPrizes _moneyPrizes;
  final List<ItemPrize> _itemPrizes = [];

  @override
  void initState() {
    super.initState();
    _moneyPrizes = MoneyPrizes();
    // Load dummy data - in a real app, this would come from an API
    _itemPrizes.addAll([
      ItemPrize(name: 'Gold Coin', imageUrl: 'assets/items/gold_coin.png', description: '24K Gold Coin'),
      ItemPrize(name: 'Silver Coin', imageUrl: 'assets/items/silver_coin.png', description: '99.9% Pure Silver'),
    ]);
  }

  void _createRoom() {
    // Validate the form if on money tab
    if (_selectedTab == 0 && _formKey.currentState?.validate() != true) {
      return;
    }
    
    // Navigate to RoomCreatedScreen with the current prize details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomCreatedScreen(
          roomId: 'ABC123', // This will be overridden by the generated ID
          gameType: widget.gameType,
          playerCount: widget.playerCount,
          moneyPrizes: _moneyPrizes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prize Details - ${widget.gameType}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Money')),
                ButtonSegment(value: 1, label: Text('Items')),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _selectedTab = selection.first;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildMoneyTab() : _buildItemsTab(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Room',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAmountField('First Jaldi Five', (value) {
                setState(() {
                  _moneyPrizes.firstJaldiFive = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.firstJaldiFive?.toString() ?? ''),
              _buildAmountField('Second Jaldi Five', (value) {
                setState(() {
                  _moneyPrizes.secondJaldiFive = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.secondJaldiFive?.toString() ?? ''),
              _buildAmountField('Third Jaldi Five', (value) {
                setState(() {
                  _moneyPrizes.thirdJaldiFive = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.thirdJaldiFive?.toString() ?? ''),
              const Divider(),
              _buildAmountField('First Top Line', (value) {
                setState(() {
                  _moneyPrizes.firstTopLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.firstTopLine?.toString() ?? ''),
              _buildAmountField('Second Top Line', (value) {
                setState(() {
                  _moneyPrizes.secondTopLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.secondTopLine?.toString() ?? ''),
              const Divider(),
              _buildAmountField('First Middle Line', (value) {
                setState(() {
                  _moneyPrizes.firstMiddleLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.firstMiddleLine?.toString() ?? ''),
              _buildAmountField('Second Middle Line', (value) {
                setState(() {
                  _moneyPrizes.secondMiddleLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.secondMiddleLine?.toString() ?? ''),
              const Divider(),
              _buildAmountField('First Last Line', (value) {
                setState(() {
                  _moneyPrizes.firstLastLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.firstLastLine?.toString() ?? ''),
              _buildAmountField('Second Last Line', (value) {
                setState(() {
                  _moneyPrizes.secondLastLine = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.secondLastLine?.toString() ?? ''),
              const Divider(),
              _buildAmountField('First Housy', (value) {
                setState(() {
                  _moneyPrizes.firstHousy = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.firstHousy?.toString() ?? ''),
              _buildAmountField('Second Housy', (value) {
                setState(() {
                  _moneyPrizes.secondHousy = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.secondHousy?.toString() ?? ''),
              _buildAmountField('Third Housy', (value) {
                setState(() {
                  _moneyPrizes.thirdHousy = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.thirdHousy?.toString() ?? ''),
              _buildAmountField('Fourth Housy', (value) {
                setState(() {
                  _moneyPrizes.fourthHousy = double.tryParse(value ?? '0');
                });
              }, _moneyPrizes.fourthHousy?.toString() ?? ''),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _itemPrizes.length,
      itemBuilder: (context, index) {
        final item = _itemPrizes[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.card_giftcard, color: Colors.amber),
            ),
            title: Text(item.name),
            subtitle: Text(item.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
            
            },
          ),
        );
      },
    );
  }

  Widget _buildAmountField(String label, Function(String?) onChanged, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixText: '₹ ',
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          if (double.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with game start
      final prizeDetails = PrizeDetails(
        gameType: widget.gameType,
        playerCount: widget.playerCount,
        moneyPrizes: _moneyPrizes,
        itemPrizes: _itemPrizes,
      );

      // Navigate to game screen with prizeDetails
     
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Game Screen')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game Type: ${prizeDetails.gameType}'),
                  Text('Players: ${prizeDetails.playerCount}'),
                  const SizedBox(height: 20),
                  const Text('Game will start soon...'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
