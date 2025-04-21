import 'package:flutter/material.dart';

import 'neopedia/components/neopedia_card.dart';
import 'neopedia/sections/clients_projects_section.dart';
import 'neopedia/sections/digital_accelerators_section.dart';
import 'neopedia/sections/history_section.dart';
import 'neopedia/sections/it_challenges_section.dart';
import 'neopedia/sections/values_culture_section.dart';

class NeopediaScreen extends StatelessWidget {
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
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.purple.shade800,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Неопедия',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        NeopediaCard(
                          title: 'История Neoflex',
                          icon: '📜',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistorySection(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        NeopediaCard(
                          title: 'IT-вызовы',
                          icon: '💻',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ITChallengesSection(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        NeopediaCard(
                          title: 'Цифровые акселераторы',
                          icon: '🚀',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DigitalAcceleratorsSection(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        NeopediaCard(
                          title: 'Клиенты и проекты',
                          icon: '🤝',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientsProjectsSection(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        NeopediaCard(
                          title: 'Ценности и культура',
                          icon: '🌟',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ValuesCultureSection(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}