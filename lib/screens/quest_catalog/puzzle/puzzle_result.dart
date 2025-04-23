import 'package:flutter/material.dart';
import '../../constants.dart';

class PuzzleResult extends StatelessWidget {
  final int coinsEarned;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const PuzzleResult({
    super.key,
    required this.coinsEarned,
    required this.onRestart,
    required this.onBack,
  });

  String _getResultMessage() {
    if (coinsEarned >= 50) {
      return 'Поздравляем! Вы собрали пазл Neoflex! 🎉';
    }
    return 'Отличная работа! Пазл собран! 😊';
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Пазл собран!',
                    style: TextStyle(
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
                        '+$coinsEarned',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/neocoins.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
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
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E0352),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF4A1A7A), width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Text('Играть снова', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A1A7A), width: 1),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Вернуться',
                      style: TextStyle(fontSize: 16, color: Color(0xFF2E0352)),
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