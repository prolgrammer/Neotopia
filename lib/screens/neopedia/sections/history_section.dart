import 'package:flutter/material.dart';
import 'package:neotopia/screens/constants.dart';

class HistorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
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
                        'История компании Neoflex',
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
                        'История компании Neoflex',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Компания Neoflex была основана в 2005 году. С тех пор она активно развивалась и участвовала в ряде значимых проектов, как в России, так и за ее пределами. Первым международным проектом стал GoldenSource 360 EDM. Уже к 2014 году Neoflex имела в своем портфеле 40 клиентов из топ-100 банков России. В 2019 году компания расширила международное присутствие, открыв офис в Йоханнесбурге, что позволило наладить взаимодействие с клиентами в Южной Африке, Анголе и Нигерии.\n'
                            'Neoflex продемонстрировала устойчивый рост благодаря развитию микросервисной архитектуры и решений в области Big Data. К 2020 году был открыт центр разработки в Пензе, а также запущен учебный центр на базе Воронежского государственного технического университета. Компания также реализовала ключевые проекты в Китае и Узбекистане, и начала сотрудничество с международными организациями, включая ACCIS.\n'
                            'В 2021 году численность команды выросла до 1160 человек, были открыты офисы в Краснодаре и Самаре. Компания запустила практику Data Science и центр мобильной разработки для платформ iOS и Android. Также стартовали образовательные и социальные инициативы, включая обучение детей из детских домов.\n'
                            'В 2022 году Neoflex сфокусировалась на цифровой трансформации в отраслях финансов, страхования и девелопмента, внедряя решения на базе Neoflex Reporting и платформы управления ML-моделями — Neoflex MLOps Center.\n'
                            'В 2023 году компания расширила направления: появились центры компетенций по видеоаналитике, BI-решениям, нагрузочному тестированию и разработке в Yandex Cloud. В 2024 году численность сотрудников превысила 1400 человек, а рост ключевых финансовых показателей составил более 25%. Были представлены новые продукты: Neoflex Reporting Risk, Neoflex Foundation, Reporting Studio и NEOMSA APIM.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Image.asset(
                        'assets/images/neotopia/history.png',
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