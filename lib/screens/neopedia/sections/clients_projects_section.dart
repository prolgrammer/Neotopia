import 'package:flutter/material.dart';
import 'package:neotopia/screens/constants.dart';

class ClientsProjectsSection extends StatelessWidget {
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
                        'Клиенты и проекты',
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
                        'Клиенты и проекты',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Решения компании Neoflex используются в 18 странах мира. Среди ее клиентов — такие известные организации, как UniCredit Bank и ТрансКапиталБанк. Также компания разработала специализированный центр планирования для логистической отрасли. Один из крупных агрохолдингов, название которого не разглашается, использует решения Neoflex на базе Big Data.',
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