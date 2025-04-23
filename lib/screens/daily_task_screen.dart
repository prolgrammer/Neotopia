import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neotopia/screens/quest_catalog/adventure/adventure_map_screen.dart';
import 'package:neotopia/screens/quest_catalog/puzzle/puzzle_screen.dart';
import 'package:neotopia/screens/quest_catalog_screen.dart';
import 'dart:math';
import '../cubits/auth_cubit.dart';
import '../models/daily_task_model.dart';
import 'constants.dart';

class DailyTasksScreen extends StatefulWidget {
  @override
  _DailyTasksScreenState createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<DailyTask> _dailyTasks = [];
  Map<String, bool> _taskCompletionStatus = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
    _listenToTaskProgress();
  }

  Future<void> _loadDailyTasks() async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Пожалуйста, войдите в аккаунт';
      });
      return;
    }

    final uid = authCubit.state.user!.uid;
    try {
      final now = DateTime.now().toUtc().add(Duration(hours: 3));
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _dailyTasks = data.values
            .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
            .toList();
      } else {
        _dailyTasks = _generateDailyTasks();
        try {
          final tasksMap = {
            'task1': _dailyTasks[0].toMap(),
            'task2': _dailyTasks[1].toMap(),
          };
          await _database.child('daily_tasks').child(dateKey).set(tasksMap);
        } catch (writeError) {
          print('Error writing daily tasks: $writeError');
          setState(() {
            _errorMessage = 'Задания созданы локально. Синхронизация не удалась.';
          });
        }
      }

      await _updateTaskCompletionStatus(uid, dateKey);
    } catch (e) {
      print('Error loading daily tasks: $e');
      setState(() {
        _errorMessage = 'Ошибка загрузки заданий: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTaskCompletionStatus(String uid, String dateKey) async {
    try {
      final progressSnapshot = await _database
          .child('users')
          .child(uid)
          .child('daily_tasks_progress')
          .child(dateKey)
          .get();

      final newStatus = <String, bool>{};
      if (progressSnapshot.exists && progressSnapshot.value != null) {
        final progressData = progressSnapshot.value as Map<dynamic, dynamic>;
        newStatus.addAll(progressData.map((taskId, data) {
          final taskProgress = Map<String, dynamic>.from(data);
          return MapEntry(
            taskId.toString(),
            taskProgress['isCompleted'] as bool? ?? false,
          );
        }));
      }
      setState(() {
        _taskCompletionStatus = newStatus;
        print('Updated task completion status: $_taskCompletionStatus');
      });
    } catch (e) {
      print('Error updating task completion status: $e');
    }
  }

  void _listenToTaskProgress() {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.user == null) return;

    final uid = authCubit.state.user!.uid;
    final now = DateTime.now().toUtc().add(Duration(hours: 3));
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    _database
        .child('users')
        .child(uid)
        .child('daily_tasks_progress')
        .child(dateKey)
        .onValue
        .listen((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final progressData = event.snapshot.value as Map<dynamic, dynamic>;
        final newStatus = progressData.map((taskId, data) {
          final taskProgress = Map<String, dynamic>.from(data);
          return MapEntry(
            taskId.toString(),
            taskProgress['isCompleted'] as bool? ?? false,
          );
        });
        setState(() {
          _taskCompletionStatus = newStatus;
          print('Task progress updated from Firebase: $_taskCompletionStatus');
        });
      }
    }, onError: (error) {
      print('Error listening to task progress: $error');
    });
  }

  List<DailyTask> _generateDailyTasks() {
    final random = Random();
    final categories = availableTasks.map((task) => task.category).toSet().toList();
    final selectedCategories = (categories..shuffle(random)).take(2).toList();
    final tasks = selectedCategories.map((category) {
      final categoryTasks = availableTasks.where((task) => task.category == category).toList();
      return categoryTasks[random.nextInt(categoryTasks.length)];
    }).toList();
    return tasks;
  }

  void _navigateToQuest(BuildContext context, DailyTask task) async {
    switch (task.category) {
      case 'Puzzle':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PuzzleScreen()),
        );
        break;
      case 'Adventure':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdventureMapScreen()),
        );
        break;
      case 'Quiz':
      case 'Pairs':
      case 'Coder':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestCatalogScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Квест пока недоступен')),
        );
        return;
    }
    // Обновляем статус заданий при возврате
    if (context.read<AuthCubit>().state.user != null) {
      final now = DateTime.now().toUtc().add(Duration(hours: 3));
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      await _updateTaskCompletionStatus(context.read<AuthCubit>().state.user!.uid, dateKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient), // Используем тот же градиент
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Верхняя плашка (как в QuestCatalogScreen)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Аватар и ник
                        Row(
                          children: [
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return CircleAvatar(
                                  radius: 24,
                                  backgroundImage: state.user?.avatarUrl != null
                                      ? FileImage(File(state.user!.avatarUrl!))
                                      : AssetImage('assets/images/avatar.jpg') as ImageProvider,
                                );
                              },
                            ),
                            SizedBox(width: 8),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return Text(
                                  state.user?.username ?? 'Пользователь',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Логотип Neotopia
                        Image.asset(
                          'assets/images/neotopia.png',
                          height: 40,
                        ),
                        // Монеты
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/neocoins.png',
                              height: 24,
                            ),
                            SizedBox(width: 4),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return Text(
                                  '${state.user?.coins ?? 0}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Белая полоска
                  Divider(
                    color: Colors.white,
                    thickness: 2,
                    height: 1,
                  ),
                  // Заголовок "Ежедневные задания"
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Text(
                      'Ежедневные задания',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Основное содержимое
                  Expanded(
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                        : _errorMessage != null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        if (_dailyTasks.isNotEmpty)
                          ElevatedButton(
                            onPressed: () => setState(() => _errorMessage = null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF4A1A7A),
                            ),
                            child: Text('Показать задания'),
                          ),
                      ],
                    )
                        : Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: _dailyTasks.length,
                        itemBuilder: (context, index) {
                          final task = _dailyTasks[index];
                          final isCompleted = _taskCompletionStatus[task.id] ?? false;
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E0352),
                                          ),
                                        ),
                                      ),
                                      if (isCompleted)
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Категория: ${task.category}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4A1A7A).withOpacity(0.7),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Цель: ${task.goal}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/neocoins.png',
                                            height: 24,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${task.rewardCoins}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E0352),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      ElevatedButton(
                                        onPressed: isCompleted
                                            ? null
                                            : () => _navigateToQuest(context, task),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCompleted
                                              ? Colors.grey
                                              : Color(0xFF4A1A7A),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          isCompleted ? 'Выполнено' : 'Начать',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Кнопка "Домой" (как в QuestCatalogScreen)
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF4A1A7A), width: 1),
                      boxShadow: [
                      BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      )],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/home.png',
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.home,
                            color: Color(0xFF2E0352),
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}