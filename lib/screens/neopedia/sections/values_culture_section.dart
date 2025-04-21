import 'package:flutter/material.dart';

class ValuesCultureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ценности и культура'),
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
                'Ценности компании',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Главная ценность Neoflex — это клиенты. Компания стремится к созданию качественных решений, которые приносят максимальную пользу. Принцип качества лежит в основе всех проектов, обеспечивая высокий уровень удовлетворенности заказчиков.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Культура и методологии',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex использует Agile-подход в работе, с акцентом на методологию Scrum для разработки. Это позволяет командам быть гибкими и эффективными. Компания поддерживает сотрудников через обучение, удаленную работу и конкурентоспособную зарплату, создавая комфортную и продуктивную среду.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}