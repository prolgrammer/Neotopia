import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/quest_cubit.dart';
import 'package:firebase_database/firebase_database.dart';

import 'constants.dart';

class QuestScreen extends StatefulWidget {
  @override
  _QuestScreenState createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
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

  int _initialQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialQuestionIndex();
  }

  Future<void> _loadInitialQuestionIndex() async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(user.uid)
            .child('questAnswers')
            .get();
        if (snapshot.exists && snapshot.value is List) {
          final answers = (snapshot.value as List).cast<String?>();
          _initialQuestionIndex = answers.indexWhere((answer) => answer == null);
          if (_initialQuestionIndex == -1) _initialQuestionIndex = answers.length - 1;
          print('Initial question index loaded from database: $_initialQuestionIndex, answers: $answers');
          setState(() {});
        }
      } catch (e) {
        print('Error loading initial question index: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestCubit(initialIndex: _initialQuestionIndex),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: kAppGradient),
          child: Column(
            children: [
              SizedBox(height: 16),
              Image.asset(
                'assets/images/neoflex_logo.png',
                height: 100,
              ),
              Expanded(
                child: BlocListener<QuestCubit, QuestState>(
                  listenWhen: (previous, current) =>
                  previous.currentQuestionIndex != current.currentQuestionIndex ||
                      current.isCompleted,
                  listener: (context, state) {
                    print('QuestCubit state changed: index=${state.currentQuestionIndex}, isCompleted=${state.isCompleted}, answers=${state.answers}');
                    if (state.isCompleted) {
                      print('Quest completed, navigating to welcome screen');
                      context
                          .read<AuthCubit>()
                          .completeQuest(context.read<AuthCubit>().state.user!.uid);
                      Navigator.pushReplacementNamed(context, '/welcome');
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      final state = context.watch<QuestCubit>().state;
                      print('Building QuestionPageView with index=${state.currentQuestionIndex}');
                      return QuestionPageView(
                        questions: questions,
                        currentIndex: state.currentQuestionIndex,
                        onAnswer: (answer, index) {
                          print('Answer submitted for question $index: $answer');
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
                ),
              ),
            ],
          ),
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
    print('Initializing QuestionPageView with initial index=${widget.currentIndex}');
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    print('Disposing QuestionPageView');
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswer(String answer, int index) async {
    print('Handling answer for question $index: $answer');
    widget.onAnswer(answer, index);
    if (index < widget.questions.length - 1) {
      print('Animating to next question: ${index + 1}');
      await _pageController.animateToPage(
        index + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building PageView with currentIndex=${widget.currentIndex}');
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDE683C)),
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
                    print('Submitting answer for question ${widget.index}: $_selectedAnswer');
                    widget.onAnswer(_selectedAnswer!);
                    setState(() {
                      _selectedAnswer = null;
                      _controller.clear();
                    });
                    FocusScope.of(context).unfocus();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF2E0352),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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