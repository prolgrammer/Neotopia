import '../../../../models/daily_task_model.dart';

const String initialCode = '''
_rotation = Tween<double>(begin: 0, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
_scale = Tween<double>(begin: 1, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
''';

const String fixedCode = '''
class MascotAnimation extends StatefulWidget {
  @override
  _MascotAnimationState createState() => _MascotAnimationState();
}

class _MascotAnimationState extends State<MascotAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    // Вставь код здесь
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset('assets/images/mascot.jpg'),
          ),
        );
      },
    );
  }
}
''';

final List<DailyTask> coderTasks = [
  DailyTask(
    id: 'coder_rotation',
    category: 'Coder',
    title: 'Первый код',
    description: 'Напиши код, чтобы маскот начал двигаться! Настрой вращение.',
    goal: 'Правильно задать end для _rotation (например, 2 * 3.14159).',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'coder_perfect',
    category: 'Coder',
    title: 'Безупречный код',
    description: 'Напиши код без ошибок с первой попытки!',
    goal: 'Завершить задание “Нео-Кодер” с первой проверки без ошибок.',
    rewardCoins: 5,
  ),
];