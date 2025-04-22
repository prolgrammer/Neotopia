import 'package:flutter/material.dart';
import 'maze_painter.dart';

class MazeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Future<bool> Function() onStep; // Изменено на Future<bool> для возврата успеха
  const MazeScreen({required this.onComplete, required this.onStep, super.key});

  @override
  _MazeScreenState createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> {
  List<List<dynamic>> maze = [
    ['S', 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 1, 0, 1, 0, 0, 0],
    [1, 0, 1, 0, 1, 0, 1, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 0, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 'E', 1],
  ];
  List<int> playerPosition = [0, 0];
  int stepCount = 0;
  bool hasTriggeredStepTask = false;

  void _resetMaze() {
    setState(() {
      playerPosition = [0, 0];
      stepCount = 0;
      hasTriggeredStepTask = false;
      print('Maze reset');
    });
  }

  void _movePlayer(int row, int col) {
    if (row < 0 || row >= 10 || col < 0 || col >= 10 || maze[row][col] == 1) {
      return;
    }
    setState(() {
      playerPosition = [row, col];
      stepCount++;
      print('Step count: $stepCount');
      if (stepCount == 5 && !hasTriggeredStepTask) {
        print('Calling onStep for adventure_steps');
        widget.onStep().then((success) {
          if (success && mounted) {
            print('Showing SnackBar for adventure_steps');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Задание выполнено! Пять шагов к успеху\nНаграда: 5 🪙',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        });
        hasTriggeredStepTask = true;
      }
      if (maze[row][col] == 'E') {
        print('Reached exit, calling onComplete');
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабиринт офиса'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/mascot.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Наш офис уже стал настолько большим, что я могу очень легко заблудиться. Помоги найти дорогу к выходу, нажимая на соседние клетки!',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTapUp: (details) {
                  final size = MediaQuery.of(context).size;
                  final cellSize = size.width / 10;
                  final row = (details.localPosition.dy / cellSize).floor();
                  final col = (details.localPosition.dx / cellSize).floor();
                  if ((row - playerPosition[0]).abs() + (col - playerPosition[1]).abs() == 1) {
                    _movePlayer(row, col);
                  }
                },
                child: CustomPaint(
                  painter: MazePainter(maze, playerPosition),
                  child: Container(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _resetMaze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Сбросить', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}