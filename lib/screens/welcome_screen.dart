import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/neoflex_logo.jpg',
                    height: 100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Добро пожаловать в Neoflex!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Вы успешно прошли квест и готовы к новым приключениям!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Навигация на главную страницу с заданиями
                    },
                    child: Text('Начать приключение'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}