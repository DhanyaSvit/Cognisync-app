import 'package:flutter/material.dart';
import 'dart:math';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late List<_CardModel> _cards;
  int? _firstIndex;
  int? _secondIndex;
  int _score = 0;
  int _matches = 0;
  bool _waiting = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final base = List.generate(6, (i) => i);
    final all = [...base, ...base];
    all.shuffle(Random());
    _cards = all.map((n) => _CardModel(n)).toList();
    _firstIndex = null;
    _secondIndex = null;
    _score = 0;
    _matches = 0;
    _waiting = false;
    setState(() {});
  }

  void _onCardTap(int idx) async {
    if (_waiting || _cards[idx].isMatched || idx == _firstIndex) return;
    setState(() {
      if (_firstIndex == null) {
        _firstIndex = idx;
      } else {
        _secondIndex = idx;
        _waiting = true;
      }
    });
    if (_secondIndex != null) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (_cards[_firstIndex!].value == _cards[_secondIndex!].value) {
        setState(() {
          _cards[_firstIndex!].isMatched = true;
          _cards[_secondIndex!].isMatched = true;
          _matches++;
          _score += 10;
        });
      } else {
        setState(() {
          _score -= 2;
        });
      }
      setState(() {
        _firstIndex = null;
        _secondIndex = null;
        _waiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  // Removed unused cardSize variable
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Memory Game', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetGame,
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Matches: $_matches/6', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) {
                  final card = _cards[idx];
                  final isFlipped = card.isMatched || idx == _firstIndex || idx == _secondIndex;
                  return GestureDetector(
                    onTap: () => _onCardTap(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isFlipped ? Colors.tealAccent : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (isFlipped)
                            BoxShadow(color: Color.alphaBlend(Colors.tealAccent.withOpacity(0.3), Colors.transparent), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                      child: Center(
                        child: isFlipped
                            ? Text('${card.value + 1}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black))
                            : const Icon(Icons.help_outline, color: Colors.white38, size: 32),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_matches == 6)
              Text('You Won! 🎉', style: TextStyle(color: Colors.tealAccent[700], fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CardModel {
  final int value;
  bool isMatched = false;
  _CardModel(this.value);
}
