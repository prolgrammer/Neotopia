import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neotopia/screens/neopedia_screen.dart';
import 'package:neotopia/screens/quest_catalog/adventure/adventure_map_screen.dart';
import 'package:neotopia/widgets/quest_card.dart';
import '../../cubits/auth_cubit.dart';
import 'constants.dart';
import 'quest_catalog/neo_coder/neo_coder_screen.dart';
import 'quest_catalog/quiz/quiz_screen.dart';
import 'quest_catalog/pair_match/pair_match_screen.dart';
import 'quest_catalog/puzzle/puzzle_screen.dart';
import 'dart:io';

class QuestCatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя плашка
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Аватар и ник
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              context.read<AuthCubit>().uploadAvatar(image);
                            }
                          },
                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return CircleAvatar(
                                radius: 24,
                                backgroundImage: state.user?.avatarUrl != null
                                    ? FileImage(File(state.user!.avatarUrl!))
                                    : AssetImage('assets/images/avatar.jpg'),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return Text(
                              state.user?.username ?? 'Пользователь',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Логотип Neotopia
                    Image.asset(
                      'assets/images/neotopia.png',
                      height: 40,
                    ),
                    // Монеты
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/neocoins.png',
                          height: 24,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${context.watch<AuthCubit>().state.user?.coins ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Белая полоска
              Divider(
                color: Colors.white,
                thickness: 2,
                height: 1,
              ),
              // Заголовок "Каталог игр"
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  'Каталог игр',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Список игр
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      QuestCard(
                        title: 'Викторина Neoflex',
                        imagePath: 'assets/images/games/quiz.png',
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
                        imagePath: 'assets/images/games/pairs.png',
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
                        imagePath: 'assets/images/games/puzzle.png',
                        description: 'Собери пазл с символикой Neoflex и получи награду!',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PuzzleScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      QuestCard(
                        title: 'Карта приключений',
                        imagePath: 'assets/images/games/map.png',
                        description: 'Исследуй виртуальную карту компании и выполняй задания!',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdventureMapScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      QuestCard(
                        title: 'Нео-Кодер',
                        imagePath: 'assets/images/games/notebook.png',
                        description: 'Реши логические задачи и стань мастером кода!',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NeoCoderScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Нижняя плашка с домиком
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Белый фон
        child: Container(
          height: 100,
          child: Center(
            child: IconButton(
              icon: Image.asset(
                'assets/images/home.png',
                height: 24, // Уменьшено пропорционально
                width: 24,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
            ),
          ),
        ),
      ),
    );
  }
}