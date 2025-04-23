import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math';
import '../../../cubits/auth_cubit.dart';
import '../../../cubits/game_cubit.dart';
import '../../../models/daily_task_model.dart';
import '../../constants.dart';
import 'quiz_data.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> selectedQuestions = [];
  List<String?> userAnswers = []; // Для хранения ответов пользователя
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int consecutiveCorrectAnswers = 0; // Для quiz_expert
  int cultureCorrectAnswers = 0; // Для quiz_culture
  bool showResult = false;
  static const int coinsPerCorrectAnswer = 10;
  List<DailyTask> _dailyTasks = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadDailyTasks();
    _selectRandomQuestions();
    _controller.forward();
  }

  Future<void> _loadDailyTasks() async {
    setState(() {
      _dailyTasks = quizTasks.where((task) => task.category == 'Quiz').toList();
      print('Loaded quiz tasks: ${_dailyTasks.map((t) => t.id).toList()}');
    });
  }

  void _selectRandomQuestions() {
    final categories = questions.map((q) => q['category'] as String).toSet();
    final random = Random();
    for (var category in categories) {
      final categoryQuestions = questions.where((q) => q['category'] == category).toList();
      if (categoryQuestions.isNotEmpty) {
        selectedQuestions.add(categoryQuestions[random.nextInt(categoryQuestions.length)]);
      }
    }
    userAnswers = List<String?>.filled(selectedQuestions.length, null);
    print('Selected questions: ${selectedQuestions.map((q) => q['question']).toList()}');
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
          content: Text(
            'Задание выполнено! ${task.title}\nНаграда: ${task.rewardCoins} 🪙',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF2E0352), // Цвет Neoflex
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _answerQuestion(String selectedOption) async {
    final currentQuestion = selectedQuestions[currentQuestionIndex];
    final isCorrect = currentQuestion['correct_answer'] == selectedOption;

    setState(() {
      userAnswers[currentQuestionIndex] = selectedOption; // Сохраняем ответ пользователя
      if (isCorrect) {
        correctAnswers++;
        consecutiveCorrectAnswers++;
        if (currentQuestion['category'] == 'Ценности и культура') {
          cultureCorrectAnswers++;
        }
      } else {
        consecutiveCorrectAnswers = 0;
      }
    });

    // Проверка заданий
    if (consecutiveCorrectAnswers >= 5) {
      final success = await _checkTask('quiz_expert');
      if (success) {
        _showTaskNotification('quiz_expert');
      }
    }
    if (cultureCorrectAnswers >= 2) {
      final success = await _checkTask('quiz_culture');
      if (success) {
        _showTaskNotification('quiz_culture');
      }
    }

    setState(() {
      _controller.reset();
      if (currentQuestionIndex < selectedQuestions.length - 1) {
        currentQuestionIndex++;
        _controller.forward();
      } else {
        // Начисляем монеты в конце игры
        context.read<GameCubit>().addCoins(correctAnswers * coinsPerCorrectAnswer);
        showResult = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Викторина Neoflex'),
        backgroundColor: Color(0xFF2E0352), // Цвет Neoflex
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient), // Градиент Neoflex
        child: showResult
            ? QuizResult(
          correctAnswers: correctAnswers,
          totalQuestions: selectedQuestions.length,
          userAnswers: userAnswers,
          questions: selectedQuestions,
          onBack: () => Navigator.pop(context),
        )
            : FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вопрос ${currentQuestionIndex + 1} из ${selectedQuestions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedQuestions[currentQuestionIndex]['question'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...(selectedQuestions[currentQuestionIndex]['options'] as String)
                    .split(',')
                    .map(
                      (option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF2E0352), // Цвет Neoflex
                        side: const BorderSide(color: Color(0xFF4A1A7A), width: 1), // Обводка
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E0352),
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}