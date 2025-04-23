import '../../../models/daily_task_model.dart';

final List<String> cardImages = [
  'assets/images/pairs/card1.png',
  'assets/images/pairs/card2.png',
  'assets/images/pairs/card3.png',
  'assets/images/pairs/card4.png',
  'assets/images/pairs/card5.png',
  'assets/images/pairs/card6.png',
];

final List<DailyTask> pairTasks = [
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
];