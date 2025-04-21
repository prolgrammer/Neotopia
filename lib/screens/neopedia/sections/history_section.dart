import 'package:flutter/material.dart';

class HistorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История Neoflex'),
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
                'Основание и развитие',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Компания Neoflex была основана в 2005 году и с тех пор стала лидером в области разработки программного обеспечения и внедрения сложных информационных систем. За годы работы компания реализовала множество крупных проектов, включая первый международный проект GoldenSource 360 EDM, который заложил основу для глобального признания.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Ключевые вехи',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'К 2014 году более 40 банков из топ-100 России стали клиентами Neoflex, что подчеркивает доверие финансового сектора к компании. Продукт Neoflex Reporting получил награду IBM 8 раз за 10 лет, демонстрируя высокое качество и инновационность решений. В 2020 году Neoflex открыл центр разработки в Пензе, расширяя свои возможности для создания передовых IT-платформ.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}