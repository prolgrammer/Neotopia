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
                'assets/images/mascot.png',
                height: 100,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: BlocConsumer<QuestCubit, QuestState>(
                  listener: (context, state) {
                    if (state.isCompleted) {
                      context.read<AuthCubit>().completeQuest(
                          context.read<AuthCubit>().state.user!.uid);
                      Navigator.pushReplacementNamed(context, '/welcome');
                    }
                  },
                  builder: (context, state) {
                    final question = questions[state.currentQuestionIndex];
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              question['question'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            if (question['type'] == 'text') ...[
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Ваш ответ',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    context.read<QuestCubit>().answerQuestion(
                                      value,
                                      onSave: (index, answer) {
                                        context.read<AuthCubit>().saveQuestAnswer(
                                          context
                                              .read<AuthCubit>()
                                              .state
                                              .user!
                                              .uid,
                                          index,
                                          answer,
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ] else ...[
                              ...question['options'].map((option) {
                                return ListTile(
                                  title: Text(option),
                                  onTap: () {
                                    context.read<QuestCubit>().answerQuestion(
                                      option,
                                      onSave: (index, answer) {
                                        context.read<AuthCubit>().saveQuestAnswer(
                                          context
                                              .read<AuthCubit>()
                                              .state
                                              .user!
                                              .uid,
                                          index,
                                          answer,
                                        );
                                      },
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}