import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/game_cubit.dart';

class NeoCoderScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    // Initialize code input
    _codeController.text = '''
_rotation = Tween<double>(begin: 0, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
_scale = Tween<double>(begin: 1, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
'''.trim();

    // Initialize success animation (default values, updated on check)
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize error shake animation
    _errorController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _errorShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0), weight: 1),
    ]).animate(_errorController);

    // Initialize fade-in animation
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  void _resetCode() {
    setState(() {
      _codeController.text = '''
_rotation = Tween<double>(begin: 0, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
_scale = Tween<double>(begin: 1, end: /* TODO */).animate(
  CurvedAnimation(parent: _controller, curve: /* TODO */),
);
'''.trim();
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

  void _checkCode() {
    final code = _codeController.text.trim();
    List<String> errors = [];

    // Split code into lines for precise validation
    final lines = code.split('\n').map((line) => line.trim()).toList();

    // Expected structure
    const rotationLine1 = r'_rotation = Tween<double>\(begin: 0, end: ([-]?\s*\d*\.?\d*\s*\*?\s*\d*\.?\d*|[0-9.-]+)\)\.animate\(';
    const rotationLine2 = r'CurvedAnimation\(parent: _controller, curve: Curves\.easeInOut\),';
    const scaleLine1 = r'_scale = Tween<double>\(begin: 1, end: ([-]?\d*\.?\d*)\)\.animate\(';
    const scaleLine2 = r'CurvedAnimation\(parent: _controller, curve: Curves\.easeInOut\),';

    // Validate line count
    if (lines.length != 6) {
      errors.add('Код должен содержать ровно 6 строк (3 для _rotation, 3 для _scale).');
    } else {
      // Validate _rotation
      if (!RegExp(rotationLine1).hasMatch(lines[0])) {
        if (!lines[0].contains('begin: 0')) {
          errors.add('Не изменяйте begin: 0 в _rotation.');
        }
        if (!lines[0].contains('Tween<double>')) {
          errors.add('Не изменяйте Tween<double> в _rotation.');
        }
        if (!lines[0].contains('.animate(')) {
          errors.add('Не удаляйте .animate( в _rotation.');
        }
      }
      if (!RegExp(rotationLine2).hasMatch(lines[1])) {
        if (!lines[1].contains('CurvedAnimation')) {
          errors.add('Не изменяйте CurvedAnimation в _rotation.');
        }
        if (!lines[1].contains('parent: _controller')) {
          errors.add('Не изменяйте parent: _controller в _rotation.');
        }
        if (!lines[1].contains('curve: Curves.easeInOut')) {
          errors.add('curve в _rotation должен быть правильной кривой анимации.');
        }
      }
      if (!lines[2].contains(');')) {
        errors.add('Не удаляйте ); в конце _rotation.');
      }

      // Validate _scale
      if (!RegExp(scaleLine1).hasMatch(lines[3])) {
        if (!lines[3].contains('begin: 1')) {
          errors.add('Не изменяйте begin: 1 в _scale.');
        }
        if (!lines[3].contains('Tween<double>')) {
          errors.add('Не изменяйте Tween<double> в _scale.');
        }
        if (!lines[3].contains('.animate(')) {
          errors.add('Не удаляйте .animate( в _scale.');
        }
      }
      if (!RegExp(scaleLine2).hasMatch(lines[4])) {
        if (!lines[4].contains('CurvedAnimation')) {
          errors.add('Не изменяйте CurvedAnimation в _scale.');
        }
        if (!lines[4].contains('parent: _controller')) {
          errors.add('Не изменяйте parent: _controller в _scale.');
        }
        if (!lines[4].contains('curve: Curves.easeInOut')) {
          errors.add('curve в _scale должен быть правильной кривой анимации.');
        }
      }
      if (!lines[5].contains(');')) {
        errors.add('Не удаляйте ); в конце _scale.');
      }
    }

    // If there are syntax errors, show them and skip animation
    if (errors.isNotEmpty) {
      setState(() {
        hasChecked = true;
        errorMessage = 'Ошибка в коде:\n- ${errors.join('\n- ')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
      return;
    }

    // Parse end values for rotation and scale
    final rotationMatch = RegExp(r'end: ([-]?\s*\d*\.?\d*\s*\*?\s*\d*\.?\d*|[0-9.-]+)').firstMatch(lines[0]);
    final scaleMatch = RegExp(r'end: ([-]?\d*\.?\d*)').firstMatch(lines[3]);
    final curveCorrect = lines[1].contains('Curves.easeInOut') && lines[4].contains('Curves.easeInOut');

    double rotationEnd = 0;
    double scaleEnd = 1;
    if (rotationMatch != null && rotationMatch.group(1) != null) {
      String rotationStr = rotationMatch.group(1)!.replaceAll(' ', '');
      print('Raw rotation end string: $rotationStr');
      // Handle expressions like "2 * 3.14159"
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

    // Update animations with input values
    setState(() {
      _rotationAnimation = Tween<double>(begin: 0, end: rotationEnd).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _scaleAnimation = Tween<double>(begin: 1, end: scaleEnd).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      hasChecked = true;
      // Check if rotation is a non-zero multiple of 2π (360°) and scale is 1.5
      final twoPi = 2 * 3.14159;
      final rotationNormalized = rotationEnd.abs() / twoPi;
      final isRotationCorrect = rotationEnd != 0 && (rotationNormalized - rotationNormalized.roundToDouble()).abs() < 0.001;
      isCorrect = curveCorrect && isRotationCorrect && (scaleEnd - 1.5).abs() < 0.001;

      _animationController.reset();
      _errorController.reset();

      if (isCorrect) {
        _animationController.forward().then((_) {
          setState(() {
            isGameOver = true;
          });
          context.read<GameCubit>().addCoins(coinsForCompletion);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Успех! Маскот ожил! 🎉')),
          );
        });
      } else {
        _animationController.forward().then((_) {
          _animationController.reset();
          _errorController.repeat(reverse: true, period: Duration(milliseconds: 300)).then((_) {
            _errorController.reset();
          });
          errorMessage = 'Ошибка! Анимация должна вращать маскота ровно на 360° (используй 2 * 3.14159 или ~6.28318) и увеличивать в 1.5 раза. Попробуй снова!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
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
      return Scaffold(
        appBar: AppBar(
          title: Text('Нео-Кодер: Анимируй Маскота!'),
          backgroundColor: Colors.purple.shade800,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Поздравляем!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Вы оживили маскота и заработали $coinsForCompletion неокоинов! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text('Играть снова'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text('Вернуться'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Нео-Кодер: Анимируй Маскота!'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Description
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Помоги маскоту Neoflex ожить! Дополни код, заменив /* TODO */ на правильные значения, чтобы маскот вращался ровно на 360 градусов и увеличивался в 1.5 раза. Для 360° используй 2 * 3.14159 или ~6.28318. Подсказка: вращение в радианах, выбери подходящую кривую анимации. Не изменяй другие части кода!',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Фиксированный код:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '''
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
'''.trim(),
                              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Code Input
                  Text(
                    'Твой код:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _codeController,
                      maxLines: 8,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _resetCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade800,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Сбросить'),
                      ),
                      ElevatedButton(
                        onPressed: _checkCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade800,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Проверить'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Animation Result
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
                                  boxShadow: [
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
                                      child: Center(child: Text('X', style: TextStyle(color: Colors.white))),
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