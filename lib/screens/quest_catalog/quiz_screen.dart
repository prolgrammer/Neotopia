import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../cubits/game_cubit.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> selectedQuestions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showResult = false;
  static const int coinsPerCorrectAnswer = 10;

  final questions = [
    {
      'category': 'История Neoflex',
      'question': 'В каком году была основана компания Neoflex?',
      'options': '2000,2005,2010,2015',
      'correct_answer': '2005',
    },
    {
      'category': 'История Neoflex',
      'question': 'Какой международный проект был первым в истории Neoflex?',
      'options': 'GoldenSource 360 EDM,Neoflex Integra,Big Data для агрохолдинга,CRM для банка',
      'correct_answer': 'GoldenSource 360 EDM',
    },
    {
      'category': 'История Neoflex',
      'question': 'Сколько банков из топ-100 России были клиентами Neoflex в 2014 году?',
      'options': '20,30,40,50',
      'correct_answer': '40',
    },
    {
      'category': 'История Neoflex',
      'question': 'Какой продукт Neoflex получил награду IBM 8 раз за 10 лет?',
      'options': 'Neoflex FrontOffice,Neoflex Integra,Neoflex Reporting,Neoflex Datagram',
      'correct_answer': 'Neoflex Reporting',
    },
    {
      'category': 'История Neoflex',
      'question': 'В каком году Neoflex открыл центр разработки в Пензе?',
      'options': '2018,2019,2020,2021',
      'correct_answer': '2020',
    },
    {
      'category': 'IT-вызовы',
      'question': 'Какой подход использует Neoflex для интеграции систем?',
      'options': 'SOA,Monolith,Microkernel,Event-Driven',
      'correct_answer': 'SOA',
    },
    {
      'category': 'IT-вызовы',
      'question': 'Какой тип данных обрабатывает платформа Neoflex Datagram?',
      'options': 'Только структурированные,Только неструктурированные,Полуструктурированные,Все типы',
      'correct_answer': 'Все типы',
    },
    {
      'category': 'IT-вызовы',
      'question': 'Какой инструмент Neoflex использует для Big Data?',
      'options': 'Hadoop,Spark,Оба,Ни один',
      'correct_answer': 'Оба',
    },
    {
      'category': 'IT-вызовы',
      'question': 'Какой метод Neoflex применяет для автоматизации отчетности ЦБ РФ?',
      'options': 'Excel,Neoflex Reporting,SQL scripts,Tableau',
      'correct_answer': 'Neoflex Reporting',
    },
    {
      'category': 'IT-вызовы',
      'question': 'Какой язык программирования используется в Neoflex Datagram для генерации кода?',
      'options': 'Java,Scala,Python,C#',
      'correct_answer': 'Scala',
    },
    {
      'category': 'Цифровые акселераторы',
      'question': 'Что такое цифровая трансформация по версии Neoflex?',
      'options': 'Автоматизация отчетов,Создание IT-платформ,Внедрение CRM,Обучение сотрудников',
      'correct_answer': 'Создание IT-платформ',
    },
    {
      'category': 'Цифровые акселераторы',
      'question': 'Какой продукт Neoflex помогает банкам с продажами?',
      'options': 'Neoflex Reporting,Neoflex FrontOffice,Neoflex Integra,Neoflex Datagram',
      'correct_answer': 'Neoflex FrontOffice',
    },
    {
      'category': 'Цифровые акселераторы',
      'question': 'Какую технологию Neoflex использует для обработки потоковых данных?',
      'options': 'FastData,Blockchain,AI,Quantum Computing',
      'correct_answer': 'FastData',
    },
    {
      'category': 'Цифровые акселераторы',
      'question': 'Какой продукт Neoflex автоматизирует работу с данными ЦБ РФ?',
      'options': 'Neoflex Reporting,Neoflex Integra,Neoflex Datagram,Neoflex FrontOffice',
      'correct_answer': 'Neoflex Reporting',
    },
    {
      'category': 'Цифровые акселераторы',
      'question': 'Какой тип архитектуры продвигает Neoflex для микросервисов?',
      'options': 'Monolith,SOA,Microservices,Serverless',
      'correct_answer': 'Microservices',
    },
    {
      'category': 'Клиенты и проекты',
      'question': 'Сколько стран используют решения Neoflex?',
      'options': '5,10,18,25',
      'correct_answer': '18',
    },
    {
      'category': 'Клиенты и проекты',
      'question': 'Какой банк является клиентом Neoflex?',
      'options': 'Сбербанк,ВТБ,UniCredit Bank,Тинькофф',
      'correct_answer': 'UniCredit Bank',
    },
    {
      'category': 'Клиенты и проекты',
      'question': 'Для какой отрасли Neoflex создал центр планирования?',
      'options': 'Банки,Логистика,Ритейл,Агропром',
      'correct_answer': 'Логистика',
    },
    {
      'category': 'Клиенты и проекты',
      'question': 'Какой агрохолдинг использует Big Data от Neoflex?',
      'options': 'Мираторг,Русагро,Неизвестно,Черкизово',
      'correct_answer': 'Неизвестно',
    },
    {
      'category': 'Клиенты и проекты',
      'question': 'Какой банк получил CRM-решение от Neoflex?',
      'options': 'ТрансКапиталБанк,ВТБ,Сбербанк,Альфа-Банк',
      'correct_answer': 'ТрансКапиталБанк',
    },
    {
      'category': 'Ценности и культура',
      'question': 'Что является главной ценностью Neoflex?',
      'options': 'Инновации,Клиенты,Прибыль,Сотрудники',
      'correct_answer': 'Клиенты',
    },
    {
      'category': 'Ценности и культура',
      'question': 'Какой подход Neoflex использует в работе?',
      'options': 'Agile,Waterfall,Lean,Kanban',
      'correct_answer': 'Agile',
    },
    {
      'category': 'Ценности и культура',
      'question': 'Как Neoflex поддерживает сотрудников?',
      'options': 'Только зарплата,Обучение,Удаленная работа,Все перечисленное',
      'correct_answer': 'Все перечисленное',
    },
    {
      'category': 'Ценности и культура',
      'question': 'Какой принцип лежит в основе проектов Neoflex?',
      'options': 'Скорость,Качество,Экономия,Риски',
      'correct_answer': 'Качество',
    },
    {
      'category': 'Ценности и культура',
      'question': 'Какую методологию разработки продвигает Neoflex?',
      'options': 'Scrum,Waterfall,PRINCE2,CMMI',
      'correct_answer': 'Scrum',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _selectRandomQuestions();
    _controller.forward();
  }

  void _selectRandomQuestions() {
    final categories = questions.map((q) => q['category'] as String).toSet();
    final random = Random();
    for (var category in categories) {
      final categoryQuestions = questions.where((q) => q['category'] == category).toList();
      if (categoryQuestions.isNotEmpty) {
        selectedQuestions.add(categoryQuestions[random.nextInt(categoryQuestions.length)]);
      }
    }
  }

  void _answerQuestion(String selectedOption) async {
    if (selectedQuestions[currentQuestionIndex]['correct_answer'] == selectedOption) {
      correctAnswers++;
      await context.read<GameCubit>().addCoins(coinsPerCorrectAnswer);
    }

    setState(() {
      _controller.reset();
      if (currentQuestionIndex < selectedQuestions.length - 1) {
        currentQuestionIndex++;
        _controller.forward();
      } else {
        showResult = true;
      }
    });
  }

  String _getResultMessage() {
    final totalQuestions = selectedQuestions.length;
    final percentage = correctAnswers / totalQuestions;

    if (percentage == 1.0) {
      return 'Ты мастер Neoflex! Все ответы правильные! 🎉';
    } else if (percentage >= 0.8) {
      return 'Отличная работа! Ты хорошо знаешь Neoflex! 💪';
    } else if (percentage >= 0.6) {
      return 'Неплохо! Ты знаком с компанией, но есть куда расти! 😎';
    } else if (percentage >= 0.4) {
      return 'Хорошая попытка! Загляни в Неопедию, чтобы узнать больше! 📚';
    } else {
      return 'Похоже, Neoflex для тебя пока загадка. Изучай Неопедию! 🧠';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Викторина Neoflex'),
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
        child: showResult
            ? Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Результат: $correctAnswers из ${selectedQuestions.length}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _getResultMessage(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
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
        )
            : FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вопрос ${currentQuestionIndex + 1} из ${selectedQuestions.length}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  selectedQuestions[currentQuestionIndex]['question'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ...(selectedQuestions[currentQuestionIndex]['options'] as String)
                    .split(',')
                    .map((option) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade700,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(option),
                  ),
                ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}