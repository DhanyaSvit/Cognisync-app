import 'package:flutter/material.dart';
import 'dart:math';

class MergeMosaic extends StatefulWidget {
  const MergeMosaic({super.key});

  @override
  State<MergeMosaic> createState() => _MergeMosaicState();
}

class _MergeMosaicState extends State<MergeMosaic> {
  static const int gridSize = 4;
  late List<List<int>> _grid;
  int _score = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    _score = 0;
    _gameOver = false;
    _addRandomTile();
    _addRandomTile();
    setState(() {});
  }

  void _addRandomTile() {
    final empty = <Map<String, int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c] == 0) empty.add({'r': r, 'c': c});
      }
    }
    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      _grid[pos['r']!][pos['c']!] = Random().nextInt(10) < 9 ? 2 : 4;
    }
  }

  bool _canMove() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c] == 0) return true;
        if (r < gridSize - 1 && _grid[r][c] == _grid[r + 1][c]) return true;
        if (c < gridSize - 1 && _grid[r][c] == _grid[r][c + 1]) return true;
      }
    }
    return false;
  }

  void _move(String direction) {
    if (_gameOver) return;
  List<List<int>> oldGrid = _grid.map((row) => List<int>.from(row)).toList();
    switch (direction) {
      case 'up':
        for (int c = 0; c < gridSize; c++) {
          List<int> col = [];
          for (int r = 0; r < gridSize; r++) col.add(_grid[r][c]);
          col = _merge(col);
          for (int r = 0; r < gridSize; r++) _grid[r][c] = col[r];
        }
        break;
      case 'down':
        for (int c = 0; c < gridSize; c++) {
          List<int> col = [];
          for (int r = gridSize - 1; r >= 0; r--) col.add(_grid[r][c]);
          col = _merge(col);
          for (int r = gridSize - 1, i = 0; r >= 0; r--, i++) _grid[r][c] = col[i];
        }
        break;
      case 'left':
        for (int r = 0; r < gridSize; r++) {
          _grid[r] = _merge(_grid[r]);
        }
        break;
      case 'right':
        for (int r = 0; r < gridSize; r++) {
          _grid[r] = _merge(_grid[r].reversed.toList()).reversed.toList();
        }
        break;
    }
    if (!_isSameGrid(oldGrid, _grid)) {
      _addRandomTile();
      if (!_canMove()) {
        _gameOver = true;
      }
      setState(() {});
    }
  }

  List<int> _merge(List<int> line) {
    List<int> newLine = line.where((v) => v != 0).toList();
    for (int i = 0; i < newLine.length - 1; i++) {
      if (newLine[i] == newLine[i + 1]) {
        newLine[i] *= 2;
        _score += newLine[i];
        newLine[i + 1] = 0;
      }
    }
    newLine = newLine.where((v) => v != 0).toList();
    while (newLine.length < gridSize) {
      newLine.add(0);
    }
    return newLine;
  }

  bool _isSameGrid(List<List<int>> a, List<List<int>> b) {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.teal[100]!;
      case 4:
        return Colors.teal[200]!;
      case 8:
        return Colors.teal[300]!;
      case 16:
        return Colors.teal[400]!;
      case 32:
        return Colors.teal[500]!;
      case 64:
        return Colors.teal[600]!;
      case 128:
        return Colors.teal[700]!;
      case 256:
        return Colors.teal[800]!;
      case 512:
        return Colors.teal[900]!;
      case 1024:
        return Colors.amber[700]!;
      case 2048:
        return Colors.amber[900]!;
      default:
        return Colors.grey[900]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Merge Mosaic', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _startGame,
            tooltip: 'Restart',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_gameOver)
                    const Text('Game Over!', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      _move('up');
                    } else if (details.primaryVelocity! > 0) {
                      _move('down');
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      _move('left');
                    } else if (details.primaryVelocity! > 0) {
                      _move('right');
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, idx) {
                          int r = idx ~/ gridSize;
                          int c = idx % gridSize;
                          int value = _grid[r][c];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _getTileColor(value),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (value > 0)
                                  BoxShadow(
                                    color: Colors.tealAccent.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: value > 0
                                  ? Text('$value', style: TextStyle(
                                      fontSize: value < 128 ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: value < 8 ? Colors.black87 : Colors.white,
                                    ))
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Swipe to move tiles. Merge them to reach higher numbers!\nTry to get 2048 or beyond!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
