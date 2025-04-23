import 'package:flutter/material.dart';
import '../../constants.dart';

class NeoCoderResult extends StatelessWidget {
  final int coinsEarned;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const NeoCoderResult({
    super.key,
    required this.coinsEarned,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 24), // Увеличено с 16 до 24
              Text(
                'Вы оживили маскота и заработали $coinsEarned неокоинов',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 16), // Увеличено с 8 до 16
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+$coinsEarned',
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
                  ),
                ],
              ),
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
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none, // Убираем подчёркивание
                  ),
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
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none, // Убираем подчёркивание
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}