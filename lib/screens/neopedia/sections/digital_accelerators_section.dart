import 'package:flutter/material.dart';

class DigitalAcceleratorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Цифровые акселераторы'),
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
              Text(
                'Цифровая трансформация',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'По версии Neoflex, цифровая трансформация — это создание IT-платформ, которые ускоряют бизнес-процессы и повышают конкурентоспособность. Компания разрабатывает решения, такие как Neoflex FrontOffice, помогающее банкам увеличивать продажи.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Технологии обработки данных',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex использует технологию FastData для обработки потоковых данных, обеспечивая реальное время анализа. Также компания продвигает архитектуру микросервисов, которая позволяет создавать гибкие и масштабируемые приложения.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Автоматизация процессов',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex Reporting автоматизирует работу с данными Центрального банка РФ, упрощая подготовку отчетов и соответствие требованиям регулятора.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}