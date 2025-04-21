import 'package:flutter/material.dart';
import '../widgets/quest_card.dart';
import 'quest_catalog/quiz_screen.dart';
import 'quest_catalog/pair_match_screen.dart';

class QuestCatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Квесты'),
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              QuestCard(
                title: 'Викторина Neoflex',
                icon: '❓',
                description: 'Проверь свои знания о компании Neoflex! Отвечай на вопросы и зарабатывай неокоины.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen()),
                  );
                },
              ),
              SizedBox(height: 16),
              QuestCard(
                title: 'Найти пары',
                icon: '🃏',
                description: 'Найди одинаковые картинки и заработай неокоины!',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PairMatchScreen()),
                  );
                },
              ),
              SizedBox(height: 16),
              QuestCard(
                title: 'Собери пазл Neoflex',
                icon: '🧩',
                description: 'Собери пазл с символикой Neoflex и получи награду!',
                onTap: () {
                  // TODO: Навигация к игре с пазлом
                },
              ),
              SizedBox(height: 16),
              QuestCard(
                title: 'Карта приключений',
                icon: '🗺️',
                description: 'Исследуй виртуальную карту компании и выполняй задания!',
                onTap: () {
                  // TODO: Навигация к карте приключений
                },
              ),
              SizedBox(height: 16),
              QuestCard(
                title: 'Нео-Кодер',
                icon: '💻',
                description: 'Реши логические задачи и стань мастером кода!',
                onTap: () {
                  // TODO: Навигация к игре Нео-Кодер
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}