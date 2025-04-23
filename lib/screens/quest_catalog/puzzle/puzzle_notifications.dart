import 'package:flutter/material.dart';
import '../../../models/daily_task_model.dart';

class PuzzleNotifications extends StatelessWidget {
  final List<DailyTask> dailyTasks;
  final List<String> completedTasks;
  final Map<String, Animation<double>> notificationAnimations;

  const PuzzleNotifications({
    super.key,
    required this.dailyTasks,
    required this.completedTasks,
    required this.notificationAnimations,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: completedTasks.map((taskId) {
        final task = dailyTasks.firstWhere(
              (t) => t.id == taskId,
          orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
        );
        if (task.id.isEmpty) return const SizedBox.shrink();
        return Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: AnimatedBuilder(
            animation: notificationAnimations[taskId]!,
            builder: (context, child) {
              final opacity = notificationAnimations[taskId]!.value;
              final offset = Offset(0, -50 * (1 - opacity));
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: offset,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E0352),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
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
                              Text(
                                'Награда: ${task.rewardCoins} 🪙',
                                style: const TextStyle(
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
    );
  }
}