import 'package:flutter/material.dart';

class ITChallengesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT-вызовы'),
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
                'Интеграция систем',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex использует подход SOA (Service-Oriented Architecture) для интеграции систем, обеспечивая гибкость и масштабируемость IT-решений. Этот метод позволяет эффективно связывать различные платформы и сервисы.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Работа с данными',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Платформа Neoflex Datagram обрабатывает все типы данных — структурированные, неструктурированные и полуструктурированные, используя язык программирования Scala для генерации кода. Для работы с Big Data компания применяет как Hadoop, так и Spark, обеспечивая высокую производительность.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Автоматизация отчетности',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex Reporting — ключевой инструмент для автоматизации отчетности, включая требования Центрального банка РФ. Этот продукт упрощает сложные процессы и обеспечивает соответствие нормативным стандартам.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}