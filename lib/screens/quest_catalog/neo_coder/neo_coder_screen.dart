import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_database/firebase_database.dart';
import '../../../../cubits/auth_cubit.dart';
import '../../../../cubits/game_cubit.dart';
import '../../../../models/daily_task_model.dart';
import '../../constants.dart';
import 'neo_coder_data.dart' as coderData;
import 'neo_coder_result.dart';

class NeoCoderScreen extends StatefulWidget {
  const NeoCoderScreen({super.key});

  @override
  _NeoCoderScreenState createState() => _NeoCoderScreenState();
}

class _NeoCoderScreenState extends State<NeoCoderScreen> with TickerProviderStateMixin {
  static const int coinsForCompletion = 50;
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _errorController;
  late Animation<double> _errorShakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool isCorrect = false;
  bool isGameOver = false;
  bool hasChecked = false;
  String errorMessage = '';
  List<DailyTask> _dailyTasks = [];
  final Map<String, bool> _taskCompletionStatus = {};
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
    _initializeCode();
    _initializeAnimations();
  }

  Future<void> _loadDailyTasks() async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dateKey = intl.DateFormat('yyyy-MM-dd').format(now);
    try {
      final snapshot = await _database.child('daily_tasks').child(dateKey).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Firebase daily_tasks/$dateKey data: $data');
        setState(() {
          _dailyTasks = data.values
              .map((task) => DailyTask.fromMap(Map<String, dynamic>.from(task)))
              .where((task) => task.category == 'Coder')
              .toList();
          print('Loaded daily coder tasks: ${_dailyTasks.map((t) => t.id).toList()}');
        });
      } else {
        print('No daily tasks found for $dateKey, falling back to coderData.coderTasks');
        setState(() {
          _dailyTasks = coderData.coderTasks;
          print('Fallback daily coder tasks: ${_dailyTasks.map((t) => t.id).toList()}');
        });
      }
    } catch (e) {
      print('Error loading daily tasks: $e, falling back to coderData.coderTasks');
      setState(() {
        _dailyTasks = coderData.coderTasks;
        print('Fallback daily coder tasks: ${_dailyTasks.map((t) => t.id).toList()}');
      });
    }
  }

  void _initializeCode() {
    _codeController.text = coderData.initialCode.trim();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0), weight: 1),
    ]).animate(_errorController);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _resetCode() {
    setState(() {
      _codeController.text = coderData.initialCode.trim();
      isCorrect = false;
      isGameOver = false;
      hasChecked = false;
      errorMessage = '';
      _animationController.reset();
      _errorController.reset();
    });
  }

  void _restartGame() {
    setState(() {
      _resetCode();
      _fadeController.forward();
    });
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
      print('Task $taskId not found in today\'s daily tasks');
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
    if (!mounted) return;

    final task = _dailyTasks.firstWhere(
          (t) => t.id == taskId,
      orElse: () => DailyTask(id: '', category: '', title: '', description: '', goal: '', rewardCoins: 0),
    );

    if (task.id.isEmpty) return;

    // Очищаем предыдущие уведомления
    ScaffoldMessenger.of(context).clearSnackBars();

    // Показываем новое уведомление
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: _buildNotificationContent(task),
          backgroundColor: const Color(0xFF2E0352),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  Widget _buildNotificationContent(DailyTask task) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Задание выполнено!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(task.title, style: const TextStyle(color: Colors.white)),
              Row(
                children: [
                  const Text('Награда: ', style: TextStyle(color: Colors.white)),
                  Text('${task.rewardCoins}', style: const TextStyle(color: Colors.amber)),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/neocoins.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkCode() {
    final code = _codeController.text.trim();
    List<String> errors = [];

    final lines = code.split('\n').map((line) => line.trim()).toList();

    const rotationLine1 = r'_rotation = Tween<double>\(begin: 0, end: ([-]?\s*\d*\.?\d*\s*\*?\s*\d*\.?\d*|[0-9.-]+)\)\.animate\(';
    const rotationLine2 = r'CurvedAnimation\(parent: _controller, curve: Curves\.easeInOut\),';
    const scaleLine1 = r'_scale = Tween<double>\(begin: 1, end: ([-]?\d*\.?\d*)\)\.animate\(';
    const scaleLine2 = r'CurvedAnimation\(parent: _controller, curve: Curves\.easeInOut\),';

    if (lines.length != 6) {
      errors.add('Код должен содержать ровно 6 строк (3 для _rotation, 3 для _scale).');
    } else {
      if (!RegExp(rotationLine1).hasMatch(lines[0])) {
        if (!lines[0].contains('begin: 0')) errors.add('Не изменяйте begin: 0 в _rotation.');
        if (!lines[0].contains('Tween<double>')) errors.add('Не изменяйте Tween<double> в _rotation.');
        if (!lines[0].contains('.animate(')) errors.add('Не удаляйте .animate( в _rotation.');
      }
      if (!RegExp(rotationLine2).hasMatch(lines[1])) {
        if (!lines[1].contains('CurvedAnimation')) errors.add('Не изменяйте CurvedAnimation в _rotation.');
        if (!lines[1].contains('parent: _controller')) errors.add('Не изменяйте parent: _controller в _rotation.');
        if (!lines[1].contains('curve: Curves.easeInOut')) errors.add('curve в _rotation должен быть правильной кривой анимации.');
      }
      if (!lines[2].contains(');')) errors.add('Не удаляйте ); в конце _rotation.');

      if (!RegExp(scaleLine1).hasMatch(lines[3])) {
        if (!lines[3].contains('begin: 1')) errors.add('Не изменяйте begin: 1 в _scale.');
        if (!lines[3].contains('Tween<double>')) errors.add('Не изменяйте Tween<double> в _scale.');
        if (!lines[3].contains('.animate(')) errors.add('Не удаляйте .animate( в _scale.');
      }
      if (!RegExp(scaleLine2).hasMatch(lines[4])) {
        if (!lines[4].contains('CurvedAnimation')) errors.add('Не изменяйте CurvedAnimation в _scale.');
        if (!lines[4].contains('parent: _controller')) errors.add('Не изменяйте parent: _controller в _scale.');
        if (!lines[4].contains('curve: Curves.easeInOut')) errors.add('curve в _scale должен быть правильной кривой анимации.');
      }
      if (!lines[5].contains(');')) errors.add('Не удаляйте ); в конце _scale.');
    }

    if (errors.isNotEmpty) {
      setState(() {
        hasChecked = true;
        errorMessage = 'Ошибка в коде:\n- ${errors.join('\n- ')}';
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                backgroundColor: const Color(0xFF2E0352),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
      });
      return;
    }

    final rotationMatch = RegExp(r'end: ([-]?\s*\d*\.?\d*\s*\*?\s*\d*\.?\d*|[0-9.-]+)').firstMatch(lines[0]);
    final scaleMatch = RegExp(r'end: ([-]?\d*\.?\d*)').firstMatch(lines[3]);
    final curveCorrect = lines[1].contains('Curves.easeInOut') && lines[4].contains('Curves.easeInOut');

    double rotationEnd = 0;
    double scaleEnd = 1;
    if (rotationMatch != null && rotationMatch.group(1) != null) {
      String rotationStr = rotationMatch.group(1)!.replaceAll(' ', '');
      print('Raw rotation end string: $rotationStr');
      if (rotationStr.contains('*')) {
        final parts = rotationStr.split('*');
        if (parts.length == 2) {
          final multiplier = double.tryParse(parts[0]) ?? 1;
          final piValue = double.tryParse(parts[1]) ?? 0;
          rotationEnd = multiplier * piValue;
        }
      } else {
        rotationEnd = double.tryParse(rotationStr) ?? 0;
      }
    }
    if (scaleMatch != null && scaleMatch.group(1) != null) {
      scaleEnd = double.tryParse(scaleMatch.group(1)!) ?? 1;
    }

    print('Parsed rotation end: $rotationEnd, scale end: $scaleEnd, curve correct: $curveCorrect');

    setState(() {
      _rotationAnimation = Tween<double>(begin: 0, end: rotationEnd).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _scaleAnimation = Tween<double>(begin: 1, end: scaleEnd).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      final twoPi = 2 * 3.14159;
      final rotationNormalized = rotationEnd.abs() / twoPi;
      final isRotationCorrect = rotationEnd != 0 && (rotationNormalized - rotationNormalized.roundToDouble()).abs() < 0.001;
      isCorrect = curveCorrect && isRotationCorrect && (scaleEnd - 1.5).abs() < 0.001;

      if (!hasChecked && isCorrect) {
        _checkTask('coder_perfect').then((success) {
          if (success && mounted) {
            print('Triggering notification for coder_perfect');
            _showTaskNotification('coder_perfect');
            _taskCompletionStatus['coder_perfect'] = true;
          }
        });
      }

      hasChecked = true;

      _animationController.reset();
      _errorController.reset();

      if (isCorrect) {
        _animationController.forward().then((_) {
          if (!mounted) return;

          setState(() => isGameOver = true);

          if (!_taskCompletionStatus.containsKey('coder_rotation') || !_taskCompletionStatus['coder_rotation']!) {
            _checkTask('coder_rotation').then((success) {
              if (success && mounted) {
                _showTaskNotification('coder_rotation');
                _taskCompletionStatus['coder_rotation'] = true;
              }
            });
          }
        });
        context.read<GameCubit>().addCoins(coinsForCompletion);
      } else {
        _animationController.forward().then((_) {
          if (!mounted) return;

          setState(() {
            _animationController.reset();
            errorMessage = 'Ошибка! Анимация должна вращать маскота ровно на 360° (используй 2 * 3.14159 или ~6.28318) и увеличивать в 1.5 раза. Попробуй снова!';
          });

          _errorController.repeat(reverse: true, period: const Duration(milliseconds: 300)).then((_) {
            if (mounted) _errorController.reset();
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                    backgroundColor: const Color(0xFF2E0352),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animationController.dispose();
    _errorController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return NeoCoderResult(
        coinsEarned: coinsForCompletion,
        onRestart: _restartGame,
        onBack: () {
          Navigator.pop(context);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Нео-Кодер: Анимируй Маскота!'),
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Помоги маскоту Neoflex ожить! Дополни код, заменив /* TODO */ на правильные значения, чтобы маскот вращался ровно на 360 градусов и увеличивался в 1.5 раза. Для 360° используй 2 * 3.14159 или ~6.28318. Подсказка: вращение в радианах, выбери подходящую кривую анимации. Не изменяй другие части кода!',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Фиксированный код:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coderData.fixedCode.trim(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Твой код:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _codeController,
                      maxLines: 8,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _resetCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E0352),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                        child: const Text('Сбросить', style: TextStyle(fontSize: 14)),
                      ),
                      ElevatedButton(
                        onPressed: _checkCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E0352),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                        child: const Text('Проверить', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _errorShakeAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF4A1A7A), width: 1),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/mascot.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading mascot.jpg: $error');
                                    return Container(
                                      color: Colors.red,
                                      child: const Center(child: Text('X', style: TextStyle(color: Colors.white))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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