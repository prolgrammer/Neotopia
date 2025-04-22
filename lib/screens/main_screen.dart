import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neotopia/screens/store_screen.dart';
import '../cubits/auth_cubit.dart';
import 'daily_task_screen.dart';
import 'neopedia_screen.dart';
import 'dart:io';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          SafeArea(
            child: Column(
              children: [
                // Плашка с аватаром и монетами
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.purple.shade800,
                  child: Row(
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
                      SizedBox(width: 16),
                      Expanded(
                        child: BlocBuilder<AuthCubit, AuthState>(
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
                      ),
                      Row(
                        children: [
                          Text(
                            '🪙 ${context.watch<AuthCubit>().state.user?.coins ?? 0}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Карточки
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        MainCard(
                          title: 'Ежедневные задания',
                          icon: '📋',
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
                          icon: '🎮',
                          onTap: () {
                            Navigator.pushNamed(context, '/quest_catalog');
                          },
                        ),
                        SizedBox(height: 16),
                        MainCard(
                          title: 'Неопедия',
                          icon: '📚',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NeopediaScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        MainCard(
                          title: 'Магазин',
                          icon: '🛒',
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
        ],
      ),
    );
  }
}

class MainCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  MainCard({
    required this.title,
    required this.icon,
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
                color: Colors.purple.shade100,
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: 40),
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