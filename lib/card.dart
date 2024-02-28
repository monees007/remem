import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'data.dart';

class CardView extends StatefulWidget {
  final String title;
  final int stackId;

  const CardView({super.key, required this.title, required this.stackId});

  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  late List<Map<String, dynamic>> _cards;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    var cards = await DatabaseHelper.instance.getCardsOfStack(widget.stackId);
    setState(() {
      _cards = cards;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if _cards is null or empty before building the UI
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            PageView.builder(
              itemCount: _cards.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final card = _cards[index];
                return GestureDetector(
                  onTap: () {
                    // Handle tap to flip card
                  },
                  child: Container(
                      child: Center(
                    child: FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      front: _buildCardSide(card['question']),
                      back: _buildCardSide(card['answer']),
                    ),
                  )),
                );
              },
            ),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: Colors.grey[300], // Background color
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.primaries[3]), // Indicator color
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _randomizeCards();
          },
          child: const Icon(Icons.shuffle), // Update icon to shuffle
        ),
      );
    }
  }

  Widget _buildCardSide(String text) {
    return SizedBox(
      width: 350,
      height: 350,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _randomizeCards() {
    setState(() {
      List<Map<String, dynamic>> shuffledCards = List.from(_cards);
      shuffledCards.shuffle();
      _cards = shuffledCards;
      _currentIndex = 0; // Reset current index after shuffling
    });
  }
}
