import 'package:flutter/material.dart';
import 'package:neotopia/screens/constants.dart';

class ITChallengesSection extends StatelessWidget {
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
                        'IT-вызовы и технологии',
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
                        'IT-вызовы и технологии',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Neoflex активно применяет подход Service-Oriented Architecture (SOA) для интеграции различных информационных систем. Платформа Neoflex Datagram способна обрабатывать все типы данных: структурированные, неструктурированные и полуструктурированные. В сфере работы с большими данными компания использует технологии Hadoop и Spark. Для автоматизации отчетности перед Центральным банком России применяется решение Neoflex Reporting, а для генерации кода в рамках платформы Datagram используется язык программирования Scala.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Image.asset(
                        'assets/images/neotopia/technology.png',
                        fit: BoxFit.contain,
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