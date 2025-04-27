import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neotopia/screens/store_screen.dart';
import '../cubits/auth_cubit.dart';
import 'constants.dart';
import 'daily_task_screen.dart';
import 'neopedia_screen.dart';
import 'dart:io';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя часть с аватаром, ником, логотипом и монетами
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
              // Карточки
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      MainCard(
                        title: 'Неопедия',
                        imagePath: 'assets/images/places/neopedia.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NeopediaScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      MainCard(
                        title: 'Ежедневные задания',
                        imagePath: 'assets/images/places/daily.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DailyTasksScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      MainCard(
                        title: 'Каталог игр',
                        imagePath: 'assets/images/places/games.png',
                        onTap: () {
                          Navigator.pushNamed(context, '/quest_catalog');
                        },
                      ),
                      SizedBox(height: 16),
                      MainCard(
                        title: 'Магазин',
                        imagePath: 'assets/images/places/market.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StoreScreen()),
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
    );
  }
}

class MainCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  MainCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: CardClipper(),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                color: Colors.white,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(2, 0), // Измените значение Offset(x, y) для смещения иконки (x - вправо, y - вниз)
                    child: Image.asset(
                      imagePath,
                      height: 60, // Измените height и width здесь, чтобы настроить размер иконки
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 20.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}