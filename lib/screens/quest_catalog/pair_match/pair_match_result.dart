import 'package:flutter/material.dart';
import '../../constants.dart';

class PairMatchResult extends StatelessWidget {
  final int coinsEarned;
  final int taskCoins;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const PairMatchResult({
    super.key,
    required this.coinsEarned,
    required this.taskCoins,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final totalCoins = coinsEarned + taskCoins;

    return Container(
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
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Вы нашли все пары и заработали $totalCoins неокоинов!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+$totalCoins',
                    style: const TextStyle(
                      fontSize: 24,
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
              if (taskCoins > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '(включая $taskCoins за задания)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRestart,
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onBack,
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}