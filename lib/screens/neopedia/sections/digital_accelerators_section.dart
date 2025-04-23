import 'package:flutter/material.dart';
import 'package:neotopia/screens/constants.dart';

class DigitalAcceleratorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Цифровые акселераторы',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Divider(
                color: Colors.white,
                thickness: 2,
                height: 1,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text(
                        'Цифровые акселераторы',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Цифровая трансформация, по мнению Neoflex, заключается в создании IT-платформ, способных адаптироваться под нужды бизнеса. Для поддержки банков в сфере продаж компания разработала продукт Neoflex FrontOffice. Для обработки потоковых данных применяется технология FastData. Кроме того, Neoflex активно продвигает микросервисную архитектуру как оптимальный подход к построению современных IT-решений.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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