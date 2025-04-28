import 'package:flutter/material.dart';
import '../../constants.dart';

class QuizResult extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final List<String?> userAnswers;
  final List<Map<String, dynamic>> questions;
  final VoidCallback onBack;

  const QuizResult({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.userAnswers,
    required this.questions,
    required this.onBack,
  });

  String _getResultMessage() {
    final percentage = correctAnswers / totalQuestions;

    if (percentage == 1.0) {
      return 'Ты мастер Neoflex! Все ответы правильные! 🎉';
    } else if (percentage >= 0.8) {
      return 'Отличная работа! Ты хорошо знаешь Neoflex! 💪';
    } else if (percentage >= 0.6) {
      return 'Неплохо! Ты знаком с компанией, но есть куда расти! 😎';
    } else if (percentage >= 0.4) {
      return 'Хорошая попытка! Загляни в Неопедию, чтобы узнать больше! 📚';
    } else {
      return 'Похоже, Neoflex для тебя пока загадка. Изучай Неопедию! 🧠';
    }
  }

  void _showErrorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF4A1A7A), width: 1),
        ),
        elevation: 8,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: kAppGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Text(
            'Мои ошибки',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final userAnswer = userAnswers[index];
              final correctAnswer = question['correct_answer'] as String;
              if (userAnswer == null || userAnswer == correctAnswer) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Вопрос: ${question['question']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '❌ Твой ответ: $userAnswer',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '✅ Правильный ответ: $correctAnswer',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4A1A7A), width: 1),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF2E0352)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const int coinsPerCorrectAnswer = 10;
    final int earnedCoins = correctAnswers * coinsPerCorrectAnswer;

    return Container(
      decoration: const BoxDecoration(gradient: kAppGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Результат: $correctAnswers из $totalQuestions',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Заработано: $earnedCoins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/neocoins.png',
                        height: 24,
                        width: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getResultMessage(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E0352), // Цвет Neoflex
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF4A1A7A), width: 1), // Обводка
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Text('Вернуться', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _showErrorsDialog(context),
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A1A7A), width: 1), // Обводка
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Мои ошибки',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E0352),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}