import 'package:flutter/material.dart';

class ClientsProjectsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Клиенты и проекты'),
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
                'Глобальное присутствие',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Решения Neoflex используются в 18 странах мира, включая Европу, Азию и Африку. Среди клиентов компании — известные банки, такие как UniCredit Bank и ТрансКапиталБанк, для которого Neoflex разработал CRM-решение.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Отраслевые проекты',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Neoflex активно работает в различных отраслях. Например, компания создала центр планирования для логистической отрасли, оптимизируя сложные процессы. Также Neofleges Big Data для агрохолдингов, хотя конкретные названия клиентов в этой области остаются конфиденциальными.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}