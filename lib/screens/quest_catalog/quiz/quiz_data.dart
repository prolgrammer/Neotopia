import '../../../models/daily_task_model.dart';

const List<Map<String, dynamic>> questions = [
  {
    'category': 'История Neoflex',
    'question': 'В каком году была основана компания Neoflex?',
    'options': '2000,2005,2010,2015',
    'correct_answer': '2005',
  },
  {
    'category': 'История Neoflex',
    'question': 'Какой международный проект был первым в истории Neoflex?',
    'options': 'GoldenSource 360 EDM,Neoflex Integra,Big Data для агрохолдинга,CRM для банка',
    'correct_answer': 'GoldenSource 360 EDM',
  },
  {
    'category': 'История Neoflex',
    'question': 'Сколько банков из топ-100 России были клиентами Neoflex в 2014 году?',
    'options': '20,30,40,50',
    'correct_answer': '40',
  },
  {
    'category': 'История Neoflex',
    'question': 'Какой продукт Neoflex получил награду IBM 8 раз за 10 лет?',
    'options': 'Neoflex FrontOffice,Neoflex Integra,Neoflex Reporting,Neoflex Datagram',
    'correct_answer': 'Neoflex Reporting',
  },
  {
    'category': 'История Neoflex',
    'question': 'В каком году Neoflex открыл центр разработки в Пензе?',
    'options': '2018,2019,2020,2021',
    'correct_answer': '2020',
  },
  {
    'category': 'IT-вызовы',
    'question': 'Какой подход использует Neoflex для интеграции систем?',
    'options': 'SOA,Monolith,Microkernel,Event-Driven',
    'correct_answer': 'SOA',
  },
  {
    'category': 'IT-вызовы',
    'question': 'Какой тип данных обрабатывает платформа Neoflex Datagram?',
    'options': 'Только структурированные,Только неструктурированные,Полуструктурированные,Все типы',
    'correct_answer': 'Все типы',
  },
  {
    'category': 'IT-вызовы',
    'question': 'Какой инструмент Neoflex использует для Big Data?',
    'options': 'Hadoop,Spark,Оба,Ни один',
    'correct_answer': 'Оба',
  },
  {
    'category': 'IT-вызовы',
    'question': 'Какой метод Neoflex применяет для автоматизации отчетности ЦБ РФ?',
    'options': 'Excel,Neoflex Reporting,SQL scripts,Tableau',
    'correct_answer': 'Neoflex Reporting',
  },
  {
    'category': 'IT-вызовы',
    'question': 'Какой язык программирования используется в Neoflex Datagram для генерации кода?',
    'options': 'Java,Scala,Python,C#',
    'correct_answer': 'Scala',
  },
  {
    'category': 'Цифровые акселераторы',
    'question': 'Что такое цифровая трансформация по версии Neoflex?',
    'options': 'Автоматизация отчетов,Создание IT-платформ,Внедрение CRM,Обучение сотрудников',
    'correct_answer': 'Создание IT-платформ',
  },
  {
    'category': 'Цифровые акселераторы',
    'question': 'Какой продукт Neoflex помогает банкам с продажами?',
    'options': 'Neoflex Reporting,Neoflex FrontOffice,Neoflex Integra,Neoflex Datagram',
    'correct_answer': 'Neoflex FrontOffice',
  },
  {
    'category': 'Цифровые акселераторы',
    'question': 'Какую технологию Neoflex использует для обработки потоковых данных?',
    'options': 'FastData,Blockchain,AI,Quantum Computing',
    'correct_answer': 'FastData',
  },
  {
    'category': 'Цифровые акселераторы',
    'question': 'Какой продукт Neoflex автоматизирует работу с данными ЦБ РФ?',
    'options': 'Neoflex Reporting,Neoflex Integra,Neoflex Datagram,Neoflex FrontOffice',
    'correct_answer': 'Neoflex Reporting',
  },
  {
    'category': 'Цифровые акселераторы',
    'question': 'Какой тип архитектуры продвигает Neoflex для микросервисов?',
    'options': 'Monolith,SOA,Microservices,Serverless',
    'correct_answer': 'Microservices',
  },
  {
    'category': 'Клиенты и проекты',
    'question': 'Сколько стран используют решения Neoflex?',
    'options': '5,10,18,25',
    'correct_answer': '18',
  },
  {
    'category': 'Клиенты и проекты',
    'question': 'Какой банк является клиентом Neoflex?',
    'options': 'Сбербанк,ВТБ,UniCredit Bank,Тинькофф',
    'correct_answer': 'UniCredit Bank',
  },
  {
    'category': 'Клиенты и проекты',
    'question': 'Для какой отрасли Neoflex создал центр планирования?',
    'options': 'Банки,Логистика,Ритейл,Агропром',
    'correct_answer': 'Логистика',
  },
  {
    'category': 'Клиенты и проекты',
    'question': 'Какой агрохолдинг использует Big Data от Neoflex?',
    'options': 'Мираторг,Русагро,Неизвестно,Черкизово',
    'correct_answer': 'Неизвестно',
  },
  {
    'category': 'Клиенты и проекты',
    'question': 'Какой банк получил CRM-решение от Neoflex?',
    'options': 'ТрансКапиталБанк,ВТБ,Сбербанк,Альфа-Банк',
    'correct_answer': 'ТрансКапиталБанк',
  },
  {
    'category': 'Ценности и культура',
    'question': 'Что является главной ценностью Neoflex?',
    'options': 'Инновации,Клиенты,Прибыль,Сотрудники',
    'correct_answer': 'Клиенты',
  },
  {
    'category': 'Ценности и культура',
    'question': 'Какой подход Neoflex использует в работе?',
    'options': 'Agile,Waterfall,Lean,Kanban',
    'correct_answer': 'Agile',
  },
  {
    'category': 'Ценности и культура',
    'question': 'Как Neoflex поддерживает сотрудников?',
    'options': 'Только зарплата,Обучение,Удаленная работа,Все перечисленное',
    'correct_answer': 'Все перечисленное',
  },
  {
    'category': 'Ценности и культура',
    'question': 'Какой принцип лежит в основе проектов Neoflex?',
    'options': 'Скорость,Качество,Экономия,Риски',
    'correct_answer': 'Качество',
  },
  {
    'category': 'Ценности и культура',
    'question': 'Какую методологию разработки продвигает Neoflex?',
    'options': 'Scrum,Waterfall,PRINCE2,CMMI',
    'correct_answer': 'Scrum',
  },
];

final List<DailyTask> quizTasks = [
  DailyTask(
    id: 'quiz_expert',
    category: 'Quiz',
    title: 'Эксперт Neoflex',
    description: 'Стань экспертом по Neoflex! Ответь на 5 вопросов без ошибок.',
    goal: 'Ответить правильно на 5 вопросов викторины подряд без неверных ответов.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'quiz_culture',
    category: 'Quiz',
    title: 'Культурный код',
    description: 'Как хорошо ты знаешь культуру Neoflex? Ответь на 1 вопрос о наших ценностях!',
    goal: 'Ответить правильно на 1 вопрос о культуре Neoflex.',
    rewardCoins: 5,
  ),
];