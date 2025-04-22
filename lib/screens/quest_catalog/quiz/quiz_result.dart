import 'package:flutter/material.dart';

class QuizResult extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onBack;

  const QuizResult({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
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

  @override
  Widget build(BuildContext context) {
    const int coinsPerCorrectAnswer = 10;
    final int earnedCoins = correctAnswers * coinsPerCorrectAnswer;

    return Center(
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
            Text(
              'Заработано: $earnedCoins 🪙',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
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
    );
  }
}