import 'package:flutter/material.dart';
import '../screens/neopedia_screen.dart';

class QuestCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final VoidCallback onTap;

  QuestCard({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white, // Белый фон
            surfaceTintColor: Colors.transparent, // Убираем налёт цвета
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Color(0xFF4A1A7A), width: 1), // Фиолетовая обводка
            ),
            elevation: 8, // Лёгкая тень
            title: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDE683C), Color(0xFF2E0352)], // Градиент Neoflex
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Белый текст для контраста с градиентом
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Закрываем диалог
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NeopediaScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Color(0xFF4A1A7A), width: 1), // Фиолетовая обводка
                    backgroundColor: Colors.white, // Белый фон
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Неопедия',
                    style: TextStyle(color: Color(0xFF2E0352)),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF4A1A7A), width: 1), // Фиолетовая обводка
                      backgroundColor: Colors.white, // Белый фон
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Закрыть',
                      style: TextStyle(color: Color(0xFF2E0352)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E0352), // Фон Neoflex
                      foregroundColor: Colors.white, // Белый текст
                      side: BorderSide(color: Color(0xFF4A1A7A), width: 1), // Фиолетовая обводка
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Начать'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF4A1A7A), width: 1), // Тонкая фиолетовая обводка
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
              decoration: BoxDecoration(
                color: Colors.white, // Белый фон боковой полосы
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
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
    );
  }
}