import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/game_cubit.dart';
import '../../../models/daily_task_model.dart';
import '../../constants.dart';
import 'puzzle_piece.dart';
import 'puzzle_result.dart';
import 'puzzle_utils.dart';
import 'puzzle_game_widget.dart';
import 'puzzle_notifications.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  List<PuzzlePiece> pieces = [];
  List<PuzzlePiece?> grid = List.filled(totalPieces, null);
  bool isGameOver = false;
  bool showFullImage = false;
  bool showPreview = true;
  late AnimationController _previewController;
  late Animation<double> _previewFade;
  Map<int, AnimationController> _highlightControllers = {};
  Map<int, Animation<double>> _highlightAnimations = {};

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
    _loadDailyTasks();
    _initializeAnimations();
    Future.delayed(const Duration(seconds: 2), () {
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

  void _initializeAnimations() {
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _previewFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeInOut),
    );
    for (int i = 0; i < totalPieces; i++) {
      _highlightControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _highlightAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _highlightControllers[i]!, curve: Curves.easeInOut),
      );
    }
  }

  Future<void> _loadDailyTasks() async {
    try {
      final now = DateTime.now().toUtc().add(const Duration(hours: 3));
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _dailyTasks = data.values
              .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
              .where((task) => task.category == 'Puzzle')
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
      if (piece.correctIndex == gridIndex) {
        print('Piece ${piece.imagePath} placed correctly at index $gridIndex');
        _highlightControllers[gridIndex]!.forward().then((_) {
          _highlightControllers[gridIndex]!.reset();
        });
        _correctPiecesInRow++;
        _checkTask('puzzle_first');
        if (_correctPiecesInRow >= 3) {
          _checkTask('puzzle_no_mistakes');
        }
      } else {
        _correctPiecesInRow = 0;
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
      if (elapsedTime <= 60) {
        _checkTask('puzzle_speed');
      }
      setState(() {
        isGameOver = true;
        showFullImage = true;
      });
      Future.delayed(const Duration(seconds: 2), () async {
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

    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );
    if (task.id.isEmpty) return;

    final isCompleted = await context.read<AuthCubit>().isDailyTaskCompleted(uid, taskId, dateKey);
    if (isCompleted) return;

    await context.read<AuthCubit>().completeDailyTask(uid, taskId, dateKey, task.rewardCoins);

    setState(() {
      _completedTasks.add(taskId);
      _notificationControllers[taskId] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _notificationAnimations[taskId] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _notificationControllers[taskId]!, curve: Curves.easeInOut),
      );
      _notificationControllers[taskId]!.forward().then((_) {
        Future.delayed(const Duration(seconds: 3), () {
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
      _highlightControllers.forEach((_, controller) {
        controller.reset();
      });
      Future.delayed(const Duration(seconds: 2), () {
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
        title: const Text('Собери пазл Neoflex'),
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: kAppGradient),
            child: showPreview || isGameOver && !showFullImage
                ? showPreview
                ? Center(
              child: FadeTransition(
                opacity: _previewFade,
                child: PuzzleGameWidget.buildFullImage(),
              ),
            )
                : PuzzleResult(
              coinsEarned: coinsForCompletion,
              onRestart: _restartGame,
              onBack: () => Navigator.pop(context),
            )
                : PuzzleGameWidget(
              pieces: pieces,
              grid: grid,
              showFullImage: showFullImage,
              isGameOver: isGameOver,
              highlightControllers: _highlightControllers,
              highlightAnimations: _highlightAnimations,
              onPieceDropped: _onPieceDropped,
            ),
          ),
          PuzzleNotifications(
            dailyTasks: _dailyTasks,
            completedTasks: _completedTasks,
            notificationAnimations: _notificationAnimations,
          ),
        ],
      ),
    );
  }
}