import 'package:flutter/material.dart';
import 'stroop_test_game.dart';
import 'memory_game.dart';
import 'image_memory_game.dart';
import 'merge_mosaic.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Games',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 1,
          children: [
            _GameCard(
              title: 'Stroop Test',
              description: 'Test your focus and cognitive control.',
              color: Colors.deepPurple,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const StroopTestGame())),
            ),
            _GameCard(
              title: 'Memory Game',
              description: 'Challenge your memory and recall.',
              color: Colors.teal,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MemoryGame())),
            ),
            _GameCard(
              title: 'Image Memory Game',
              description: 'Memorize the images and recall their positions!',
              color: Colors.orange,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImageMemoryGame()),
              ),
            ),
            _GameCard(
              title: 'Merge Mosaic',
              description: 'Slide and merge tiles to reach the highest score!',
              color: Colors.amber,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MergeMosaic())),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
