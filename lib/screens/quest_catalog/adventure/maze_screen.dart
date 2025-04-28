import 'package:flutter/material.dart';
import '../../constants.dart';
import 'maze_painter.dart';

class MazeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Future<bool> Function() onStep;
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
            _showTaskNotification(
              title: 'Пять шагов к успеху',
              reward: 5,
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

  void _showTaskNotification({required String title, required int reward}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Задание выполнено!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Награда: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '$reward',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/neocoins.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E0352),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабиринт офиса'),
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                        ),
                        child: Image.asset(
                          'assets/images/mascot.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading mascot.jpg: $error');
                            return Container(
                              color: Colors.red,
                              child: const Center(child: Text('X', style: TextStyle(color: Colors.white))),
                            );
                          },
                        ),
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
                  backgroundColor: const Color(0xFF2E0352),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.black26,
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