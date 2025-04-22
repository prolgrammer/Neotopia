import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/game_cubit.dart';

class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  _AdventureMapScreenState createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> with TickerProviderStateMixin {
  static const int coinsPerInfoPoint = 10;
  static const int coinsForMaze = 20;
  final List<int> visitedPoints = [];
  bool isGameOver = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _markerController;
  late Animation<Offset> _markerAnimation;
  late Offset _currentMarkerPosition;

  // Матрица офиса: 0 = проход, 1 = стена, 'E' = вход
  final List<List<dynamic>> officeMap = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 0, 1, 1, 0, 1, 1, 0, 1],
    [1, 1, 0, 1, 0, 0, 0, 1, 0, 1],
    [1, 1, 0, 1, 0, 0, 0, 1, 0, 0],
    [1, 1, 0, 1, 0, 0, 0, 1, 0, 1],
    [1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
    [1, 1, 0, 1, 1, 1, 0, 0, 0, 1],
    ['E', 0, 0, 1, 1, 1, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  // Координаты точек интереса в матрице [row, col]
  final Map<int, List<int>> pointPositions = {
    1: [8, 2], // Точка 1: Первый текст
    2: [1, 2], // Точка 2: Второй текст
    3: [1, 5], // Точка 3: Третий текст
    4: [1, 8], // Точка 4: Четвёртый текст
    5: [4, 9], // Точка 5: Лабиринт
  };

  @override
  void initState() {
    super.initState();
    // Инициализация анимаций
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _markerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _markerAnimation = Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Установка начальной позиции маркера на входе ('E', [8, 0])
    final cellSize = MediaQuery.of(context).size.width / 10;
    _currentMarkerPosition = Offset(0 * cellSize, 8 * cellSize); // Вход: [8, 0]
    _markerAnimation = Tween<Offset>(begin: _currentMarkerPosition, end: _currentMarkerPosition).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.easeInOut),
    );
  }

  void _moveMarker(int pointIndex) {
    final cellSize = MediaQuery.of(context).size.width / 10;
    final newPosition = Offset(
      pointPositions[pointIndex]![1] * cellSize,
      pointPositions[pointIndex]![0] * cellSize,
    );
    setState(() {
      _markerAnimation = Tween<Offset>(begin: _currentMarkerPosition, end: newPosition).animate(
        CurvedAnimation(parent: _markerController, curve: Curves.easeInOut),
      );
      _currentMarkerPosition = newPosition;
      _markerController.forward(from: 0);
    });
  }

  void _showInfoDialog(BuildContext context, int pointIndex) {
    if (pointIndex > visitedPoints.length + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала посетите предыдущие точки!')),
      );
      return;
    }

    String title;
    String content;
    switch (pointIndex) {
      case 1:
        title = 'Вход в офис Neoflex';
        content =
        'Добро пожаловать в Neoflex! С этого входа в 2005 году началась наша история. Здесь мы мечтали о технологиях, которые изменят мир! 🚀';
        break;
      case 2:
        title = 'Зал инноваций';
        content =
        'В 2010 году здесь родились наши первые проекты для банков и ритейла. Эти решения стали фундаментом успеха Neoflex! 💡';
        break;
      case 3:
        title = 'Комната культуры';
        content =
        'Наша культура — это люди и идеи. В этом месте мы создали сообщество, где каждый голос важен! 🤝';
        break;
      case 4:
        title = 'Технический хаб';
        content =
        'Сердце наших инноваций! Здесь команды создают передовые технологии, двигающие Neoflex вперёд! 🖥️';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!visitedPoints.contains(pointIndex)) {
                setState(() {
                  visitedPoints.add(pointIndex);
                  context.read<GameCubit>().addCoins(coinsPerInfoPoint);
                  _moveMarker(pointIndex);
                });
              }
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showMaze(BuildContext context) {
    if (visitedPoints.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала посетите все информационные точки!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MazeScreen(
          onComplete: () {
            Navigator.pop(context);
            setState(() {
              visitedPoints.add(5);
              context.read<GameCubit>().addCoins(coinsForMaze);
              _moveMarker(5);
              isGameOver = true;
            });
          },
        ),
      ),
    );
  }

  void _restartGame() {
    setState(() {
      visitedPoints.clear();
      isGameOver = false;
      final cellSize = MediaQuery.of(context).size.width / 10;
      _currentMarkerPosition = Offset(0 * cellSize, 8 * cellSize); // Вход: [8, 0]
      _markerAnimation = Tween<Offset>(begin: _currentMarkerPosition, end: _currentMarkerPosition).animate(
        CurvedAnimation(parent: _markerController, curve: Curves.easeInOut),
      );
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _markerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = MediaQuery.of(context).size.width / 10;
    if (isGameOver) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Карта приключений'),
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Поздравляем! 🎉',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Вы исследовали офис Neoflex и покорили лабиринт! Заработано ${visitedPoints.length * coinsPerInfoPoint + coinsForMaze} неокоинов! 🏆',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Играть снова', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Вернуться', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта приключений'),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Добро пожаловать в финальный квест Neoflex! Исследуйте наш офис, посещая точки интереса в порядке их появления. Каждая точка расскажет часть нашей истории, а финальная точка приведёт вас к лабиринту — не так просто, как кажется! 🌟',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: OfficeMapPainter(officeMap),
                      child: Container(),
                    ),
                    // Point 1: Первый текст
                    Positioned(
                      left: pointPositions[1]![1] * cellSize,
                      top: pointPositions[1]![0] * cellSize,
                      child: GestureDetector(
                        onTap: () => _showInfoDialog(context, 1),
                        child: Icon(
                          Icons.location_pin,
                          color: visitedPoints.contains(1) ? Colors.green : Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                    // Point 2: Второй текст
                    if (visitedPoints.contains(1))
                      Positioned(
                        left: pointPositions[2]![1] * cellSize,
                        top: pointPositions[2]![0] * cellSize,
                        child: GestureDetector(
                          onTap: () => _showInfoDialog(context, 2),
                          child: Icon(
                            Icons.location_pin,
                            color: visitedPoints.contains(2) ? Colors.green : Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    // Point 3: Третий текст
                    if (visitedPoints.contains(2))
                      Positioned(
                        left: pointPositions[3]![1] * cellSize,
                        top: pointPositions[3]![0] * cellSize,
                        child: GestureDetector(
                          onTap: () => _showInfoDialog(context, 3),
                          child: Icon(
                            Icons.location_pin,
                            color: visitedPoints.contains(3) ? Colors.green : Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    // Point 4: Четвёртый текст
                    if (visitedPoints.contains(3))
                      Positioned(
                        left: pointPositions[4]![1] * cellSize,
                        top: pointPositions[4]![0] * cellSize,
                        child: GestureDetector(
                          onTap: () => _showInfoDialog(context, 4),
                          child: Icon(
                            Icons.location_pin,
                            color: visitedPoints.contains(4) ? Colors.green : Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    // Point 5: Лабиринт
                    if (visitedPoints.contains(4))
                      Positioned(
                        left: pointPositions[5]![1] * cellSize,
                        top: pointPositions[5]![0] * cellSize,
                        child: GestureDetector(
                          onTap: () => _showMaze(context),
                          child: Icon(
                            Icons.star,
                            color: visitedPoints.contains(5) ? Colors.green : Colors.yellow,
                            size: 40,
                          ),
                        ),
                      ),
                    // Маркер игрока
                    AnimatedBuilder(
                      animation: _markerAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: _markerAnimation.value.dx,
                          top: _markerAnimation.value.dy,
                          child: Image.asset(
                            'assets/images/mascot.jpg',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfficeMapPainter extends CustomPainter {
  final List<List<dynamic>> officeMap;

  OfficeMapPainter(this.officeMap);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10;
    final floorPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade200],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final wallPaint = Paint()
      ..color = Colors.blueGrey.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Отрисовка пола
    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
        if (officeMap[row][col] != 1) {
          canvas.drawRect(rect, floorPaint);
          // Текстура ковра для дорог
          if (officeMap[row][col] == 0 || officeMap[row][col] == 'E') {
            canvas.drawCircle(
              Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2),
              cellSize / 10,
              Paint()
                ..color = Colors.blueGrey.shade300.withOpacity(0.3)
                ..style = PaintingStyle.fill,
            );
          }
        }
      }
    }

    // Отрисовка стен (тонкие линии с тенями)
    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        if (officeMap[row][col] == 1) {
          // Тень для стен
          if (col < 9 && officeMap[row][col + 1] != 1) {
            canvas.drawLine(
              Offset((col + 1) * cellSize + 2, row * cellSize),
              Offset((col + 1) * cellSize + 2, (row + 1) * cellSize),
              shadowPaint,
            );
          }
          if (row < 9 && officeMap[row + 1][col] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, (row + 1) * cellSize + 2),
              Offset((col + 1) * cellSize, (row + 1) * cellSize + 2),
              shadowPaint,
            );
          }
          // Стены
          if (col < 9 && officeMap[row][col + 1] != 1) {
            canvas.drawLine(
              Offset((col + 1) * cellSize, row * cellSize),
              Offset((col + 1) * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          if (row < 9 && officeMap[row + 1][col] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, (row + 1) * cellSize),
              Offset((col + 1) * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          if (col == 0 || officeMap[row][col - 1] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, row * cellSize),
              Offset(col * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          if (row == 0 || officeMap[row - 1][col] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, row * cellSize),
              Offset((col + 1) * cellSize, row * cellSize),
              wallPaint,
            );
          }
        }
      }
    }

    // Метка входа
    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        if (officeMap[row][col] == 'E') {
          // Рамка двери
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            Paint()
              ..color = Colors.brown.shade400
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          textPaint.text = const TextSpan(
            text: 'Вход',
            style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
          );
          textPaint.layout();
          textPaint.paint(canvas, Offset(col * cellSize + 10, row * cellSize + cellSize));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MazeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const MazeScreen({required this.onComplete, super.key});

  @override
  _MazeScreenState createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> {
  // Статический лабиринт: 0 = проход, 1 = стена, 'S' = старт, 'E' = выход
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
  List<int> playerPosition = [0, 0]; // Начальная позиция (S)

  void _resetMaze() {
    setState(() {
      playerPosition = [0, 0]; // Возврат на старт
    });
  }

  void _movePlayer(int row, int col) {
    if (row < 0 || row >= 10 || col < 0 || col >= 10 || maze[row][col] == 1) {
      return; // Нельзя двигаться (граница или стена)
    }
    setState(() {
      playerPosition = [row, col];
      if (maze[row][col] == 'E') {
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

class MazePainter extends CustomPainter {
  final List<List<dynamic>> maze;
  final List<int> playerPosition;

  MazePainter(this.maze, this.playerPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10;
    final wallPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    final pathPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purple.shade100, Colors.blue.shade100],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final playerPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    final startPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.fill;
    final exitPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    // Тень для стен
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
        if (maze[row][col] == 1) {
          canvas.drawRect(rect.shift(const Offset(2, 2)), shadowPaint);
          canvas.drawRect(rect, wallPaint); // Стена
        } else if (maze[row][col] == 'E') {
          canvas.drawRect(rect, exitPaint); // Выход
        } else if (maze[row][col] == 'S') {
          canvas.drawRect(rect, startPaint); // Старт
        } else {
          canvas.drawRect(rect, pathPaint); // Проход
        }
      }
    }

    // Игрок с пульсацией
    canvas.drawCircle(
      Offset(
        playerPosition[1] * cellSize + cellSize / 2,
        playerPosition[0] * cellSize + cellSize / 2,
      ),
      cellSize / 3,
      playerPaint,
    );
    canvas.drawCircle(
      Offset(
        playerPosition[1] * cellSize + cellSize / 2,
        playerPosition[0] * cellSize + cellSize / 2,
      ),
      cellSize / 2.5,
      Paint()
        ..color = Colors.blueAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}