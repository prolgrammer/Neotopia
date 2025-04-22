import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/game_cubit.dart';
import '../../../models/daily_task_model.dart';
import '../../../models/daily_task_progress_model.dart';

class PuzzleScreen extends StatefulWidget {
  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  static const int gridRows = 3;
  static const int gridColumns = 3;
  static const int totalPieces = 9;
  static const int coinsForCompletion = 50;
  static const double imageAspectRatio = 333 / 188;

  List<String> pieceImages = List.generate(
    totalPieces,
        (index) => 'assets/images/puzzle/piece_$index.png',
  );

  List<PuzzlePiece> pieces = [];
  List<PuzzlePiece?> grid = List.filled(totalPieces, null);
  bool isGameOver = false;
  bool showFullImage = false;
  bool showPreview = true;
  late AnimationController _previewController;
  late Animation<double> _previewFade;
  Map<int, AnimationController> _highlightControllers = {};
  Map<int, Animation<double>> _highlightAnimations = {};

  // Для отслеживания заданий
  List<DailyTask> _dailyTasks = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _correctPiecesInRow = 0;
  DateTime? _startTime;
  List<String> _completedTasks = [];
  Map<String, AnimationController> _notificationControllers = {};
  Map<String, Animation<double>> _notificationAnimations = {};

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // Загрузка ежедневных заданий
    _loadDailyTasks();
    // Инициализация анимации превью
    _previewController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _previewFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeInOut),
    );
    // Инициализация анимаций подсветки
    for (int i = 0; i < totalPieces; i++) {
      _highlightControllers[i] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
      _highlightAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _highlightControllers[i]!, curve: Curves.easeInOut),
      );
    }
    // Начало превью
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showPreview = false;
        });
        _previewController.forward().then((_) {
          _initializeGame();
        });
      }
    });
  }

  Future<void> _loadDailyTasks() async {
    try {
      final now = DateTime.now().toUtc().add(Duration(hours: 3)); // МСК
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _dailyTasks = data.values
              .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading daily tasks: $e');
    }
  }

  void _initializeGame() {
    print('Initializing puzzle game');
    pieces.clear();
    grid = List.filled(totalPieces, null);
    _correctPiecesInRow = 0;
    _startTime = DateTime.now();
    for (int i = 0; i < totalPieces; i++) {
      pieces.add(PuzzlePiece(
        imagePath: pieceImages[i],
        correctIndex: i,
      ));
    }
    pieces.shuffle(Random());
    setState(() {});
  }

  void _onPieceDropped(int gridIndex, PuzzlePiece piece, {bool fromGrid = false}) async {
    print('Dropped piece ${piece.imagePath} at gridIndex=$gridIndex, fromGrid=$fromGrid');
    setState(() {
      if (!fromGrid) {
        pieces.remove(piece);
      }
      if (grid[gridIndex] != null) {
        pieces.add(grid[gridIndex]!);
      }
      grid[gridIndex] = piece;
      // Проверка правильности
      if (piece.correctIndex == gridIndex) {
        print('Piece ${piece.imagePath} placed correctly at index $gridIndex');
        _highlightControllers[gridIndex]!.forward().then((_) {
          _highlightControllers[gridIndex]!.reset();
        });
        _correctPiecesInRow++;
        // Проверка задания "puzzle_first" (1 кусок)
        _checkTask('puzzle_first');
        // Проверка задания "puzzle_no_mistakes" (3 куска без ошибок)
        if (_correctPiecesInRow >= 3) {
          _checkTask('puzzle_no_mistakes');
        }
      } else {
        _correctPiecesInRow = 0; // Сбрасываем счетчик при ошибке
      }
      _checkCompletion();
    });
  }

  void _checkCompletion() async {
    bool isComplete = true;
    for (int i = 0; i < totalPieces; i++) {
      if (grid[i] == null || grid[i]!.correctIndex != i) {
        isComplete = false;
        break;
      }
    }
    if (isComplete) {
      print('Puzzle completed!');
      final elapsedTime = DateTime.now().difference(_startTime!).inSeconds;
      // Проверка задания "puzzle_speed" (менее 60 секунд)
      if (elapsedTime <= 60) {
        _checkTask('puzzle_speed');
      }
      setState(() {
        isGameOver = true;
        showFullImage = true;
      });
      Future.delayed(Duration(seconds: 2), () async {
        if (mounted) {
          setState(() {
            showFullImage = false;
          });
          await context.read<GameCubit>().addCoins(coinsForCompletion);
        }
      });
    }
  }

  void _checkTask(String taskId) async {
    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null) return;

    final now = DateTime.now().toUtc().add(Duration(hours: 3));
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    // Проверяем, является ли задание текущим
    final task = _dailyTasks.firstWhere((t) => t.id == taskId, orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0));
    if (task.id.isEmpty) return;

    // Проверяем, не завершено ли задание
    final isCompleted = await context.read<AuthCubit>().isDailyTaskCompleted(uid, taskId, dateKey);
    if (isCompleted) return;

    // Завершаем задание
    await context.read<AuthCubit>().completeDailyTask(uid, taskId, dateKey, task.rewardCoins);

    // Показываем уведомление
    setState(() {
      _completedTasks.add(taskId);
      _notificationControllers[taskId] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
      _notificationAnimations[taskId] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _notificationControllers[taskId]!, curve: Curves.easeInOut),
      );
      _notificationControllers[taskId]!.forward().then((_) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            _notificationControllers[taskId]!.reverse().then((_) {
              setState(() {
                _completedTasks.remove(taskId);
                _notificationControllers[taskId]!.dispose();
                _notificationControllers.remove(taskId);
                _notificationAnimations.remove(taskId);
              });
            });
          }
        });
      });
    });
  }

  void _restartGame() {
    setState(() {
      isGameOver = false;
      showFullImage = false;
      showPreview = true;
      _previewController.reset();
      _highlightControllers.forEach((index, controller) {
        controller.reset();
      });
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showPreview = false;
          });
          _previewController.forward().then((_) {
            _initializeGame();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _previewController.dispose();
    _highlightControllers.forEach((_, controller) => controller.dispose());
    _notificationControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Собери пазл Neoflex'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: showPreview
                ? Center(
              child: FadeTransition(
                opacity: _previewFade,
                child: _buildFullImage(),
              ),
            )
                : isGameOver && !showFullImage
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Поздравляем!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Вы собрали пазл и заработали $coinsForCompletion неокоинов! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        _restartGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade800,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text('Играть снова'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade800,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text('Вернуться'),
                    ),
                  ],
                ),
              ),
            )
                : Center(
              child: Padding(
                padding: EdgeInsets.only(top: 32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth * 0.95;
                    final maxHeight = (constraints.maxHeight - 32) * 0.75;
                    final cardWidth = maxWidth / gridColumns;
                    final cardHeight = maxHeight / gridRows;
                    final cardSize = min(cardWidth, cardHeight * imageAspectRatio) / imageAspectRatio;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: gridColumns * cardSize * imageAspectRatio,
                            maxHeight: gridRows * cardSize,
                          ),
                          child: showFullImage
                              ? _buildFullImage()
                              : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridColumns,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: imageAspectRatio,
                            ),
                            itemCount: totalPieces,
                            itemBuilder: (context, index) {
                              final piece = grid[index];
                              final isCorrect = piece != null && piece.correctIndex == index;
                              return AnimatedBuilder(
                                animation: _highlightControllers[index]!,
                                builder: (context, child) {
                                  final highlightOpacity = _highlightAnimations[index]!.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: highlightOpacity > 0
                                          ? Border.all(
                                        color: Colors.yellow.withOpacity(highlightOpacity),
                                        width: 4,
                                      )
                                          : null,
                                    ),
                                    child: DragTarget<PuzzlePiece>(
                                      builder: (context, candidateData, rejectedData) {
                                        return piece != null
                                            ? Draggable<PuzzlePiece>(
                                          data: piece,
                                          feedback: Material(
                                            elevation: 8,
                                            borderRadius: _getBorderRadius(index),
                                            child: Container(
                                              width: cardSize * imageAspectRatio,
                                              height: cardSize,
                                              child: ClipRRect(
                                                borderRadius: _getBorderRadius(index),
                                                child: Image.asset(
                                                  piece.imagePath,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: _getBorderRadius(index),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: _getBorderRadius(index),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: _getBorderRadius(index),
                                              child: Image.asset(
                                                piece.imagePath,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          onDragCompleted: () {
                                            print('Drag completed for piece ${piece.imagePath} from grid index $index');
                                            setState(() {
                                              grid[index] = null;
                                            });
                                          },
                                          maxSimultaneousDrags: isCorrect ? 0 : 1,
                                        )
                                            : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: _getBorderRadius(index),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                      onWillAccept: (_) => !isCorrect,
                                      onAccept: (droppedPiece) {
                                        _onPieceDropped(
                                          index,
                                          droppedPiece,
                                          fromGrid: grid.contains(droppedPiece),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!showFullImage && pieces.isNotEmpty)
                          Container(
                            height: cardSize + 16,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: pieces.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Draggable<PuzzlePiece>(
                                    data: pieces[index],
                                    feedback: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: cardSize * imageAspectRatio,
                                        height: cardSize,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            pieces[index].imagePath,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      width: cardSize * imageAspectRatio,
                                      height: cardSize,
                                      color: Colors.grey[200],
                                    ),
                                    child: Container(
                                      width: cardSize * imageAspectRatio,
                                      height: cardSize,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          pieces[index].imagePath,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Уведомления о выполненных заданиях
          ..._completedTasks.map((taskId) {
            final task = _dailyTasks.firstWhere((t) => t.id == taskId, orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0));
            if (task.id.isEmpty) return SizedBox.shrink();
            return Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: _notificationAnimations[taskId]!,
                builder: (context, child) {
                  final opacity = _notificationAnimations[taskId]!.value;
                  final offset = Offset(0, -50 * (1 - opacity));
                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: offset,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 32),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Задание выполнено!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Награда: ${task.rewardCoins} 🪙',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFullImage() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: imageAspectRatio,
      ),
      itemCount: totalPieces,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: _getBorderRadius(index),
          child: Image.asset(
            pieceImages[index],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image ${pieceImages[index]}: $error');
              return Container(
                color: Colors.red,
                child: Center(child: Text('X', style: TextStyle(color: Colors.white))),
              );
            },
          ),
        );
      },
    );
  }

  BorderRadius _getBorderRadius(int index) {
    final row = index ~/ gridColumns;
    final col = index % gridColumns;
    if (row == 0 && col == 0) {
      return BorderRadius.only(topLeft: Radius.circular(16));
    } else if (row == 0 && col == gridColumns - 1) {
      return BorderRadius.only(topRight: Radius.circular(16));
    } else if (row == gridRows - 1 && col == 0) {
      return BorderRadius.only(bottomLeft: Radius.circular(16));
    } else if (row == gridRows - 1 && col == gridColumns - 1) {
      return BorderRadius.only(bottomRight: Radius.circular(16));
    }
    return BorderRadius.zero;
  }
}

class PuzzlePiece {
  final String imagePath;
  final int correctIndex;

  PuzzlePiece({
    required this.imagePath,
    required this.correctIndex,
  });
}