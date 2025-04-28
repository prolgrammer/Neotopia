import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/game_cubit.dart';
import '../../../models/daily_task_model.dart';
import '../../constants.dart';
import 'pair_match_data.dart' as pairData;
import 'pair_match_widgets.dart';
import 'pair_match_result.dart';
import 'package:firebase_database/firebase_database.dart';

class PairMatchScreen extends StatefulWidget {
  const PairMatchScreen({super.key});

  @override
  _PairMatchScreenState createState() => _PairMatchScreenState();
}

class _PairMatchScreenState extends State<PairMatchScreen> with TickerProviderStateMixin {
  static const int gridRows = 4;
  static const int gridColumns = 3;
  static const int totalPairs = 6;
  static const int coinsForCompletion = 50;

  List<CardModel> cards = [];
  int? firstFlippedIndex;
  int? secondFlippedIndex;
  bool isProcessing = false;
  bool isGameOver = false;
  bool isFirstPairAttempt = true;
  int matchedPairs = 0;
  List<DailyTask> _dailyTasks = [];
  final Map<String, bool> _taskCompletionStatus = {};
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
    _initializeGame();
  }

  Future<void> _loadDailyTasks() async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dateKey = intl.DateFormat('yyyy-MM-dd').format(now);
    try {
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _dailyTasks = data.values
              .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
              .where((task) => task.category == 'Pairs')
              .toList();
          print('Loaded daily pair tasks: ${_dailyTasks.map((t) => t.id).toList()}');
        });
      } else {
        setState(() {
          _dailyTasks = [];
          print('No daily tasks found for $dateKey');
        });
      }
    } catch (e) {
      print('Error loading daily tasks: $e');
    }
  }

  void _initializeGame() {
    print('Initializing game with $gridRows rows and $gridColumns columns');
    cards.clear();
    final List<String> duplicatedImages = [...pairData.cardImages, ...pairData.cardImages];
    duplicatedImages.shuffle(Random());
    for (int i = 0; i < gridRows * gridColumns; i++) {
      cards.add(CardModel(
        imagePath: duplicatedImages[i],
        isFlipped: false,
        isMatched: false,
      ));
    }
    print('Cards initialized: ${cards.map((c) => c.imagePath).toList()}');
    setState(() {
      isFirstPairAttempt = true;
      matchedPairs = 0;
      isGameOver = false;
      firstFlippedIndex = null;
      secondFlippedIndex = null;
      isProcessing = false;
      _taskCompletionStatus.clear();
    });
  }

  void _onCardTapped(int index) async {
    print('Tapped card $index: isProcessing=$isProcessing, isFlipped=${cards[index].isFlipped}, isMatched=${cards[index].isMatched}, isGameOver=$isGameOver');
    if (isProcessing || isGameOver || cards[index].isFlipped || cards[index].isMatched) {
      print('Tap ignored due to conditions');
      return;
    }

    setState(() {
      cards[index] = cards[index].copyWith(isFlipped: true);
      print('Card $index flipped');
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
      print('First card flipped: $index');
    } else if (secondFlippedIndex == null) {
      secondFlippedIndex = index;
      isProcessing = true;
      print('Second card flipped: $index');

      if (cards[firstFlippedIndex!].imagePath == cards[secondFlippedIndex!].imagePath) {
        print('Match found!');
        setState(() {
          cards[firstFlippedIndex!] = cards[firstFlippedIndex!].copyWith(isMatched: true);
          cards[secondFlippedIndex!] = cards[secondFlippedIndex!].copyWith(isMatched: true);
          matchedPairs++;
        });

        if (isFirstPairAttempt) {
          final success = await _checkTask('pairs_quick');
          if (success) {
            _showTaskNotification('pairs_quick');
            _taskCompletionStatus['pairs_quick'] = true;
          }
        }
        isFirstPairAttempt = false;

        if (matchedPairs >= 4) {
          final success = await _checkTask('pairs_clear');
          if (success) {
            _showTaskNotification('pairs_clear');
            _taskCompletionStatus['pairs_clear'] = true;
          }
        }

        _resetSelection();
        if (cards.every((card) => card.isMatched)) {
          print('Game over! Awarding $coinsForCompletion coins');
          await Future.delayed(const Duration(milliseconds: 500)); // Delay to allow SnackBar to show
          setState(() {
            isGameOver = true;
          });
          await context.read<GameCubit>().addCoins(coinsForCompletion);
        }
      } else {
        print('No match, flipping back');
        isFirstPairAttempt = false;
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          cards[firstFlippedIndex!] = cards[firstFlippedIndex!].copyWith(isFlipped: false);
          cards[secondFlippedIndex!] = cards[secondFlippedIndex!].copyWith(isFlipped: false);
        });
        _resetSelection();
      }
    }
  }

  void _resetSelection() {
    firstFlippedIndex = null;
    secondFlippedIndex = null;
    isProcessing = false;
    print('Selection reset');
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  Future<bool> _checkTask(String taskId) async {
    print('Checking task: $taskId');
    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null) {
      print('No user logged in');
      return false;
    }

    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dateKey = intl.DateFormat('yyyy-MM-dd').format(now);

    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );
    if (task.id.isEmpty) {
      print('Task $taskId not found in today\'s daily tasks');
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

  void _showTaskNotification(String taskId) {
    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );
    if (task.id.isEmpty) {
      print('No task found for $taskId, skipping notification');
      return;
    }
    if (mounted) {
      print('Showing SnackBar for $taskId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Задание выполнено!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Награда: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${task.rewardCoins}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/images/neocoins.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
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
          elevation: 10,
        ),
      ).closed.then((reason) {
        print('SnackBar for $taskId closed with reason: $reason');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Найди пары'),
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: isGameOver
            ? PairMatchResult(
          coinsEarned: coinsForCompletion,
          onRestart: _restartGame,
          onBack: () => Navigator.pop(context),
        )
            : Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 54),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.9;
                  final maxHeight = (constraints.maxHeight - 54) * 0.65;
                  final cardWidth = maxWidth / gridColumns;
                  final cardHeight = maxHeight / gridRows;
                  final cardSize = min(cardWidth, cardHeight);

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: gridColumns * cardSize,
                      maxHeight: gridRows * cardSize,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: gridRows * gridColumns,
                        itemBuilder: (context, index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                print('InkWell tapped for card $index');
                                _onCardTapped(index);
                              },
                              child: CardWidget(card: cards[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}