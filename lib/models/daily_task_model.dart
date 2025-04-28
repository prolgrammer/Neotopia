class DailyTask {
  final String id;
  final String category;
  final String title;
  final String description;
  final String goal;
  final int rewardCoins;

  DailyTask({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.goal,
    required this.rewardCoins,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'goal': goal,
      'rewardCoins': rewardCoins,
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      goal: map['goal'] as String,
      rewardCoins: map['rewardCoins'] as int,
    );
  }
}

final List<DailyTask> availableTasks = [
  DailyTask(
    id: 'quiz_expert',
    category: 'Quiz',
    title: 'Эксперт Neoflex',
    description: 'Стань экспертом по Neoflex! Ответь на 5 вопросов без ошибок.',
    goal: 'Ответить на все вопросы викторины правильно',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'quiz_culture',
    category: 'Quiz',
    title: 'Культурный код',
    description: 'Как хорошо ты знаешь культуру Neoflex? Ответь на 1 вопрос о наших ценностях!',
    goal: 'Ответить правильно на 1 вопрос о культуре Neoflex. (5 вопрос)',
    rewardCoins: 5,
  ),
  // Найти пары
  DailyTask(
    id: 'pairs_quick',
    category: 'Pairs',
    title: 'Быстрая пара',
    description: 'Маскот спрятал логотипы Neoflex! Найди пару одинаковых карточек за один ход.',
    goal: 'Найти 1 пару одинаковых карточек с первой попытки.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'pairs_clear',
    category: 'Pairs',
    title: 'Очистка стола',
    description: 'Помоги маскоту убрать половину карточек с поля!',
    goal: 'Найти 4 пары одинаковых карточек.',
    rewardCoins: 5,
  ),
  // Пазл
  DailyTask(
    id: 'puzzle_first',
    category: 'Puzzle',
    title: 'Первый кусочек',
    description: 'Начни собирать логотип Neoflex! Поставь один кусок пазла на место.',
    goal: 'Правильно разместить 1 кусок пазла.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'puzzle_speed',
    category: 'Puzzle',
    title: 'Скоростная сборка',
    description: 'Собери пазл быстрее маскота! Заверши пазл за 1 минуту.',
    goal: 'Полностью собрать пазл менеее чем за 60 секунд.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'puzzle_no_mistakes',
    category: 'Puzzle',
    title: 'Точный сборщик',
    description: 'Поставь 3 куска пазла без ошибок!',
    goal: 'Разместить 3 куска пазла подряд без неправильных ходов.',
    rewardCoins: 5,
  ),
  // Карта приключений
  DailyTask(
    id: 'adventure_first',
    category: 'Adventure',
    title: 'Первый шаг в офисе',
    description: 'Маскот встречает тебя у входа! Посети первую точку на карте.',
    goal: 'Посетить точку 1 и закрыть диалог.',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'adventure_steps',
    category: 'Adventure',
    title: 'Шаги в лабиринте',
    description: 'Помоги маскоту в лабиринте! Пройди 5 клеток в лабиринте.',
    goal: 'Сделать 5 ходов в лабиринте (достижение выхода не требуется).',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'adventure_master',
    category: 'Adventure',
    title: 'Мастер лабиринта',
    description: 'Найди выход из офиса Neoflex! Заверши лабиринт.',
    goal: 'Достигнуть выхода в лабиринте.',
    rewardCoins: 5,
  ),
  // Нео-Кодер
  DailyTask(
    id: 'coder_rotation',
    category: 'Coder',
    title: 'Вращающийся код',
    description: 'Напиши код, чтобы маскот начал двигаться! Настрой вращение.',
    goal: 'Правильно задать end для _rotation (например, 2 * 3.14159).',
    rewardCoins: 5,
  ),
  DailyTask(
    id: 'coder_perfect',
    category: 'Coder',
    title: 'Безупречный код',
    description: 'Напиши код без ошибок с первой попытки!',
    goal: 'Завершить задание “Нео-Кодер” с первой проверки без ошибок.',
    rewardCoins: 5,
  ),
];