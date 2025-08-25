import 'package:flutter/material.dart';
  // Removed unnecessary import
import 'dart:async';
import 'dart:math';

class ImageMemoryGame extends StatefulWidget {
  const ImageMemoryGame({super.key});

  @override
  State<ImageMemoryGame> createState() => _ImageMemoryGameState();
}

class GameImage {
  final String assetPath;
  final String label;
  const GameImage(this.assetPath, this.label);
}

class _ImageMemoryGameState extends State<ImageMemoryGame> {
  Widget _buildGrid({required bool showIcons}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, idx) {
        final imgIdx = positions[idx];
        return GestureDetector(
          onTap: showIcons || answered ? null : () => _onAnswer(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: showIcons
                  ? Colors.white
                  : (answered && idx == answerIndex)
                      ? (roundImages[positions[idx]] == targetImage ? Colors.greenAccent : Colors.redAccent)
                      : Colors.blue[700],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: showIcons
                  ? Image.asset(roundImages[imgIdx].assetPath, width: 48, height: 48)
                  : Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
  static final List<GameImage> allImages = [
  GameImage('assets/game_image/campfire.png', 'Campfire'),
  GameImage('assets/game_image/tent.png', 'Tent'),
  GameImage('assets/game_image/fish.png', 'Fish'),
  GameImage('assets/game_image/bowl.png', 'Bowl'),
  GameImage('assets/game_image/woman1.png', 'Woman1'),
  GameImage('assets/game_image/woman2.png', 'Woman2'),
  GameImage('assets/game_image/volcano.png', 'Volcano'),
  GameImage('assets/game_image/necklace.png', 'Necklace'),
  ];

  int round = 1;
  int score = 0;
  int totalRounds = 8;
  int gridCount = 8;
  int memorizeSeconds = 8;
  int answerSeconds = 3;
  bool showImages = true;
  bool showResult = false;
  bool answered = false;
  int? answerIndex;
  late List<GameImage> roundImages;
  late List<int> positions;
  late GameImage targetImage;
  Timer? _timer;
  int timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound() {
    setState(() {
      showImages = true;
      showResult = false;
      answered = false;
      answerIndex = null;
      gridCount = 8;
  roundImages = List<GameImage>.from(allImages)..shuffle();
      // Always take 8 unique images
      roundImages = roundImages.take(gridCount).toList();
      positions = List.generate(gridCount, (i) => i)..shuffle();
      targetImage = roundImages[Random().nextInt(roundImages.length)];
      // Set memorize time by round
      if (round == 1) {
        memorizeSeconds = 8;
      } else if (round == 2) memorizeSeconds = 7;
      else if (round == 3) memorizeSeconds = 6;
      else if (round == 4) memorizeSeconds = 5;
      else if (round == 5) memorizeSeconds = 4;
      else memorizeSeconds = 3;
      answerSeconds = 3;
      timeLeft = memorizeSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          timer.cancel();
          _showNumbers();
        }
      });
    });
  }

  void _showNumbers() {
    setState(() {
      showImages = false;
      timeLeft = answerSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0 && !answered) {
          timer.cancel();
          _onAnswer(-1); // Timeout
        }
      });
    });
  }

  void _onAnswer(int idx) {
    if (answered) return;
    _timer?.cancel();
    setState(() {
      answered = true;
      answerIndex = idx;
      showResult = true;
      if (idx >= 0 && roundImages[positions[idx]] == targetImage) {
        score++;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (round < totalRounds) {
        setState(() => round++);
        _startRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Image Memory Game', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Round $round / $totalRounds', style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Score: $score', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (showImages)
              Column(
                children: [
                  const Text('Memorize the images', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildGrid(showIcons: true),
                  const SizedBox(height: 12),
                  Text('Time left: $timeLeft', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16)),
                ],
              )
            else ...[
              Text('Where was this?', style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              Image.asset(targetImage.assetPath, width: 64, height: 64),
              const SizedBox(height: 12),
              _buildGrid(showIcons: false),
              const SizedBox(height: 12),
              Text('Time left: $timeLeft', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16)),
            ],
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  (answerIndex != null && answerIndex! >= 0 && roundImages[positions[answerIndex!]] == targetImage)
                      ? 'Correct!'
                      : 'Wrong!',
                  style: TextStyle(
                    color: (answerIndex != null && answerIndex! >= 0 && roundImages[positions[answerIndex!]] == targetImage)
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (round > totalRounds && showResult)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  children: [
                    Text('Game Over!\nFinal Score: $score',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.tealAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          onPressed: () {
                            setState(() {
                              round = 1;
                              score = 0;
                            });
                            _startRound();
                          },
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
