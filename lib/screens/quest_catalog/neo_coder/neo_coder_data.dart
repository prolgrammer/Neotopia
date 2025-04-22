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
    id: 'coder_correct',
    category: 'Coder',
    title: 'Код с первого раза',
    description: 'Введи правильный код для анимации маскота с первой попытки!',
    goal: 'Ввести правильный код без ошибок при первой проверке.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'coder_complete',
    category: 'Coder',
    title: 'Оживший маскот',
    description: 'Заверши задачу и оживи маскота с правильной анимацией!',
    goal: 'Успешно анимировать маскота (360° вращение, увеличение в 1.5 раза).',
    rewardCoins: 5,
  ),
];