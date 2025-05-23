import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/game_cubit.dart';
import '../../../models/daily_task_model.dart';
import '../../constants.dart';
import 'office_map_painter.dart';
import 'maze_screen.dart';

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

  List<DailyTask> _dailyTasks = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String> _completedTasks = [];
  Map<String, AnimationController> _notificationControllers = {};
  Map<String, Animation<double>> _notificationAnimations = {};

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

  final Map<int, List<int>> pointPositions = {
    1: [8, 2],
    2: [1, 2],
    3: [1, 5],
    4: [1, 8],
    5: [4, 9],
  };

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
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
    final cellSize = MediaQuery.of(context).size.width / 10;
    _currentMarkerPosition = Offset(0 * cellSize, 8 * cellSize);
    _markerAnimation = Tween<Offset>(begin: _currentMarkerPosition, end: _currentMarkerPosition).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadDailyTasks() async {
    try {
      final now = DateTime.now().toUtc().add(Duration(hours: 3));
      final dateKey = intl.DateFormat('yyyy-MM-dd').format(now);
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _dailyTasks = data.values
              .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
              .toList();
          print('Loaded daily tasks: ${_dailyTasks.map((t) => t.id).toList()}');
        });
      } else {
        print('No daily tasks found for $dateKey');
      }
    } catch (e) {
      print('Error loading daily tasks: $e');
    }
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

  void _showNotification(String taskId) {
    if (!mounted) {
      print('Widget not mounted, skipping notification for $taskId');
      return;
    }
    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );
    if (task.id.isEmpty) {
      print('Task $taskId not found in daily tasks');
      return;
    }
    print('Showing SnackBar for $taskId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Задание выполнено!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(task.title, style: const TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      const Text('Награда: ', style: TextStyle(color: Colors.white)),
                      Text('${task.rewardCoins}', style: const TextStyle(color: Colors.amber)),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/neocoins.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading neocoins.png: $error');
                          return const Icon(Icons.error, color: Colors.red, size: 20);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E0352),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool> _checkTask(String taskId) async {
    print('Checking task: $taskId');
    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null) {
      print('No user logged in');
      return false;
    }

    final now = DateTime.now().toUtc().add(Duration(hours: 3));
    final dateKey = intl.DateFormat('yyyy-MM-dd').format(now);

    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );
    if (task.id.isEmpty) {
      print('Task $taskId not found in daily tasks');
      return false;
    }

    final isCompleted = await context.read<AuthCubit>().isDailyTaskCompleted(uid, taskId, dateKey);
    if (isCompleted) {
      print('Task $taskId already completed');
      return false;
    }

    try {
      print('Completing task $taskId with reward ${task.rewardCoins}');
      await context.read<AuthCubit>().completeDailyTask(uid, taskId, dateKey, task.rewardCoins);
      print('Daily task $taskId completed, ${task.rewardCoins} coins added');
      return true;
    } catch (e) {
      print('Error completing task $taskId: $e');
      return false;
    }
  }

  void _showInfoDialog(BuildContext context, int pointIndex) {
    if (pointIndex > visitedPoints.length + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сначала посетите предыдущие точки!', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2E0352),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    String title;
    String content;
    switch (pointIndex) {
      case 1:
        title = 'Вход в офис Neoflex';
        content = 'Добро пожаловать в Neoflex! С этого входа в 2005 году началась наша история. Здесь мы мечтали о технологиях, которые изменят мир! 🚀';
        break;
      case 2:
        title = 'Зал инноваций';
        content = 'В 2010 году здесь родились наши первые проекты для банков и ритейла. Эти решения стали фундаментом успеха Neoflex! 💡';
        break;
      case 3:
        title = 'Комната культуры';
        content = 'Наша культура — это люди и идеи. В этом месте мы создали сообщество, где каждый голос важен! 🤝';
        break;
      case 4:
        title = 'Технический хаб';
        content = 'Сердце наших инноваций! Здесь команды создают передовые технологии, двигающие Neoflex впёрёд! 🖥️';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        content: Text(content, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!visitedPoints.contains(pointIndex)) {
                setState(() {
                  visitedPoints.add(pointIndex);
                  context.read<GameCubit>().addCoins(coinsPerInfoPoint);
                  _moveMarker(pointIndex);
                });
                if (pointIndex == 1) {
                  final success = await _checkTask('adventure_first');
                  if (success) {
                    _showNotification('adventure_first');
                  }
                }
              }
            },
            child: const Text('Закрыть', style: TextStyle(color: Color(0xFF2E0352))),
          ),
        ],
      ),
    );
  }

  void _showMaze(BuildContext context) {
    if (visitedPoints.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сначала посетите все информационные точки!', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2E0352),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MazeScreen(
          onComplete: () async {
            final success = await _checkTask('adventure_master');
            setState(() {
              visitedPoints.add(5);
              context.read<GameCubit>().addCoins(coinsForMaze);
              _moveMarker(5);
              isGameOver = true;
              // Показываем уведомление после рендера экрана результатов
              if (success && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  print('Triggering notification for adventure_master after frame');
                  _showNotification('adventure_master');
                });
              } else {
                print('Failed to complete adventure_master or widget not mounted');
              }
            });
            Navigator.pop(context);
          },
          onStep: () async {
            return await _checkTask('adventure_steps');
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
      _currentMarkerPosition = Offset(0 * cellSize, 8 * cellSize);
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
    _notificationControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = MediaQuery.of(context).size.width / 10;
    if (isGameOver) {
      final totalCoins = visitedPoints.length * coinsPerInfoPoint + coinsForMaze;
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kAppGradient),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Поздравляем!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Вы исследовали офис Neoflex и покорили лабиринт! Заработано $totalCoins неокоинов',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+$totalCoins',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/neocoins.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading neocoins.png: $error');
                          return const Icon(Icons.error, color: Colors.red, size: 24);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E0352),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: Colors.black26,
                    ),
                    child: const Text(
                      'Играть снова',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E0352),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: Colors.black26,
                    ),
                    child: const Text(
                      'Вернуться',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
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
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: kAppGradient),
            child: FadeTransition(
              opacity: _fadeAnimation,
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
                        AnimatedBuilder(
                          animation: _markerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              left: _markerAnimation.value.dx,
                              top: _markerAnimation.value.dy,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
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
        ],
      ),
    );
  }
}