import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neotopia/cubits/auth_cubit.dart';
import 'package:neotopia/screens/neopedia/components/neopedia_card.dart';
import 'package:neotopia/screens/neopedia/sections/clients_projects_section.dart';
import 'package:neotopia/screens/neopedia/sections/digital_accelerators_section.dart';
import 'package:neotopia/screens/neopedia/sections/history_section.dart';
import 'package:neotopia/screens/neopedia/sections/it_challenges_section.dart';
import 'package:neotopia/screens/neopedia/sections/values_culture_section.dart';
import 'package:neotopia/screens/constants.dart';
import 'dart:io';

class NeopediaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Прокручиваемый контент
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Верхняя панель
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
                      // Заголовок "Неопедия"
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text(
                          'Неопедия',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Список карточек
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            NeopediaCard(
                              title: 'История компании Neoflex',
                              imagePath: 'assets/images/categories/history.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistorySection(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            NeopediaCard(
                              title: 'IT-вызовы и технологии',
                              imagePath: 'assets/images/categories/IT.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ITChallengesSection(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            NeopediaCard(
                              title: 'Цифровые акселераторы',
                              imagePath: 'assets/images/categories/accelerator.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DigitalAcceleratorsSection(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            NeopediaCard(
                              title: 'Клиенты и проекты',
                              imagePath: 'assets/images/categories/clients.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientsProjectsSection(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            NeopediaCard(
                              title: 'Ценности и культура',
                              imagePath: 'assets/images/categories/culture.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ValuesCultureSection(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32), // Дополнительный отступ внизу
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Фиксированная кнопка "домик"
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF4A1A7A), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/home.png',
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading home.png: $error');
                          return Icon(
                            Icons.home,
                            color: Color(0xFF2E0352),
                            size: 24,
                          );
                        },
                      ),
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