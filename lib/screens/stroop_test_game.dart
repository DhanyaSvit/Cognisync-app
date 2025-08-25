import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class StroopTestGame extends StatefulWidget {
  const StroopTestGame({super.key});

  @override
  State<StroopTestGame> createState() => _StroopTestGameState();
}

class _StroopTestGameState extends State<StroopTestGame> {
  // Level system
  int _level = 1; // 1: Easy, 2: Medium, 3: Hard
  int _score = 0;
  int _round = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  int _timer = 6;
  late List<String> colorNames;
  late List<Color> colors;
  late String _word;
  late Color _color;
  late Color _bgColor;
  late List<int> _answerIndices;
  late final Random _random;
  late int _timerMax;
  late int _optionsCount;
  late List<Color> _allColors;
  late List<String> _allColorNames;
  bool _timerActive = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _allColorNames = [
      'Red',
      'Yellow',
      'Blue',
      'Green',
      'White',
      'Violet',
      'Black',
      'Pink',
    ];
    _allColors = [
      Colors.red,
      Colors.yellow,
      Colors.blue,
      Colors.green,
      Colors.white,
      Color(0xFF8F00FF), // Violet
      Colors.black,
      Colors.pink,
    ];
    _setLevel(1);
    // Do not start round until user presses Start
  }

  void _setLevel(int level) {
    _level = level;
    colorNames = List<String>.from(_allColorNames);
    colors = List<Color>.from(_allColors);
    _optionsCount = 6;
    if (_level == 1) {
      _timerMax = 6;
    } else if (_level == 2) {
      _timerMax = 4;
    } else {
      _timerMax = 2;
    }
    _gameStarted = false;
  }

  void _nextRound() {
    setState(() {
      _round++;
      _showResult = false;
      _timer = _timerMax;
      _timerActive = true;
      // Pick word and color
      int wordIdx = _random.nextInt(colorNames.length);
      int colorIdx = _random.nextInt(colors.length);
      _word = colorNames[wordIdx];
      _color = colors[colorIdx];
      // Pick a background color different from text color
      List<Color> bgChoices = colors.where((c) => c != _color).toList();
      _bgColor = bgChoices[_random.nextInt(bgChoices.length)];
      // Pick 6 unique answer options, always include the correct color
      List<int> indices = List.generate(colorNames.length, (i) => i);
      indices.shuffle(_random);
      if (!indices.take(6).contains(colorIdx)) {
        indices[0] = colorIdx; // Ensure correct answer is present
      }
      _answerIndices = indices.take(_optionsCount).toList();
    });
    _startTimer();
  }

  void _startTimer() {
    _timerActive = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_timerActive) return false;
      setState(() {
        _timer--;
      });
      if (_timer <= 0) {
        _timerActive = false;
        _showResult = true;
        _isCorrect = false;
        Future.delayed(const Duration(milliseconds: 800), _nextRound);
        return false;
      }
      return true;
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _round = 0;
      _gameStarted = true;
    });
    _nextRound();
  }

  void _checkAnswer(String answer) {
    if (!_timerActive) return;
    setState(() {
      _isCorrect = answer == _colorName(_color);
      if (_isCorrect) _score++;
      _showResult = true;
      _timerActive = false;
    });
    Future.delayed(const Duration(milliseconds: 800), _nextRound);
  }

  String _colorName(Color color) {
    int idx = colors.indexOf(color);
    if (idx >= 0 && idx < colorNames.length) return colorNames[idx];
    // fallback for all colors
    int allIdx = _allColors.indexOf(color);
    if (allIdx >= 0 && allIdx < _allColorNames.length) return _allColorNames[allIdx];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Stroop Test', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _level,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Easy')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Hard')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _setLevel(val);
                      _score = 0;
                      _round = 0;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_gameStarted) ...[
                const SizedBox(height: 60),
                // Glassmorphic Start Button
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _startGame,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                SizedBox(width: 8),
                                Text('Start', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 8),
                Text('Round $_round', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 8),
                Text('Score: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Timer
                Text('Time: $_timer', style: TextStyle(color: _timer <= 2 ? Colors.redAccent : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: _color.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Text(
                    _word,
                    style: TextStyle(
                      color: _color,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 3 columns x 2 rows grid for answers
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const NeverScrollableScrollPhysics(),
                    children: _answerIndices.map((idx) {
                      final name = colorNames[idx];
                      final color = colors[idx];
                      return ElevatedButton(
                        onPressed: _showResult ? null : () => _checkAnswer(name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          foregroundColor: color,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                if (_showResult)
                  Text(
                    _isCorrect ? 'Correct!' : 'Wrong!',
                    style: TextStyle(
                      color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
