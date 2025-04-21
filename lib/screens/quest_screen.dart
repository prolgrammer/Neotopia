import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/quest_cubit.dart';

class QuestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Как вас зовут?',
      'type': 'text',
    },
    {
      'question': 'Сколько вам лет?',
      'type': 'text',
    },
    {
      'question': 'Что больше всего привлекает вас в Neoflex?',
      'type': 'choice',
      'options': [
        '🚀 Возможность развиваться и делать крутые проекты',
        '💼 Классная команда и атмосфера',
        '🎁 Неокоины и мерч, конечно!',
        '🧠 Хочу узнать, что за зверь такой Neoflex',
      ],
    },
    {
      'question': 'Откуда узнали о компании?',
      'type': 'text',
    },
    {
      'question':
      'Какой суперспособностью вы бы хотели обладать в команде Neoflex?',
      'type': 'choice',
      'options': [
        'Всё автоматизировать',
        'Читать мысли клиента',
        'Никогда не багать',
        'Превращать кофе в код',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestCubit(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Image.asset(
                'assets/images/mascot.jpg',
                height: 100,
              ),
            ),
            BlocConsumer<QuestCubit, QuestState>(
              listener: (context, state) {
                if (state.isCompleted) {
                  context
                      .read<AuthCubit>()
                      .completeQuest(context.read<AuthCubit>().state.user!.uid);
                  Navigator.pushReplacementNamed(context, '/welcome');
                }
              },
              builder: (context, state) {
                return QuestionPageView(
                  questions: questions,
                  currentIndex: state.currentQuestionIndex,
                  onAnswer: (answer, index) {
                    context.read<QuestCubit>().answerQuestion(
                      answer,
                      onSave: (index, answer) {
                        context.read<AuthCubit>().saveQuestAnswer(
                          context.read<AuthCubit>().state.user!.uid,
                          index,
                          answer,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionPageView extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final Function(String, int) onAnswer;

  QuestionPageView({
    required this.questions,
    required this.currentIndex,
    required this.onAnswer,
  });

  @override
  _QuestionPageViewState createState() => _QuestionPageViewState();
}

class _QuestionPageViewState extends State<QuestionPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswer(String answer, int index) async {
    // Вызываем onAnswer для сохранения ответа
    widget.onAnswer(answer, index);
    // Ждем завершения анимации
    await _pageController.animateToPage(
      widget.currentIndex + 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        return QuestionPage(
          question: widget.questions[index],
          index: index,
          totalQuestions: widget.questions.length,
          onAnswer: (answer) => _onAnswer(answer, index),
          progress: (index + 1) / widget.questions.length,
        );
      },
    );
  }
}

class QuestionPage extends StatefulWidget {
  final Map<String, dynamic> question;
  final int index;
  final int totalQuestions;
  final Function(String) onAnswer;
  final double progress;

  QuestionPage({
    required this.question,
    required this.index,
    required this.totalQuestions,
    required this.onAnswer,
    required this.progress,
  });

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String? _selectedAnswer;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 16),
                Text(
                  'Вопрос ${widget.index + 1} из ${widget.totalQuestions}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  widget.question['question'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                if (widget.question['type'] == 'text') ...[
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ваш ответ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
                    onSubmitted: (_) {
                      // Предотвращаем сброс фокуса клавиатуры
                    },
                  ),
                ] else ...[
                  ...widget.question['options'].map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedAnswer,
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswer = value;
                        });
                      },
                    );
                  }).toList(),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedAnswer != null && _selectedAnswer!.isNotEmpty
                      ? () {
                    widget.onAnswer(_selectedAnswer!);
                    setState(() {
                      _selectedAnswer = null;
                      _controller.clear();
                    });
                    // Скрываем клавиатуру
                    FocusScope.of(context).unfocus();
                  }
                      : null,
                  child: Text('Далее'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}