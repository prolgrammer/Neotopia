# Neotopia
Neotopia — это увлекательная мобильная игра, разработанная на Flutter, которая погружает игроков в виртуальный мир компании Neoflex. Выполняйте квесты, решайте головоломки, программируйте анимации и зарабатывайте неокоины для покупок в игровом магазине.

# Основные возможности  
- Разнообразные квесты: Программируйте анимации маскота, собирайте пазлы, проходите викторины, находите пары и исследуйте офис Neoflex.  
- Ежедневные задачи: Выполняйте задания, чтобы заработать неокоины.  
- Игровой магазин: Покупайте мерч за неокоины.  
- Неопедия: Узнайте о культуре, истории и проектах Neoflex.  
- Аутентификация: Вход через Firebase для сохранения прогресса.  

# Шаги установки:

- Клонируйте репозиторий:  
https://github.com/prolgrammer/Neotopia.git

- Откройте проект через ваше средство разработки


- Установите зависимости:
flutter pub get


- Запустите приложение:
flutter run

# Структура проекта

neotopia/  
├── android/                    # Конфигурация Android  
├── ios/                        # Конфигурация iOS  
├── lib/  
│   ├── cubits/                 # Cubit'ы для управления состоянием  
│   │   ├── auth_cubit.dart     # Аутентификация  
│   │   ├── game_cubit.dart     # Игровая логика (монеты, прогресс)  
│   │   ├── quest_cubit.dart    # Управление квестами  
│   ├── models/                 # Модели данных  
│   │   ├── daily_task_model.dart  
│   │   ├── daily_task_progress_model.dart  
│   │   ├── merch_model.dart  
│   │   ├── user_model.dart  
│   ├── screens/                # Экраны приложения  
│   │   ├── neotopia/           # Экран Неопедии  
│   │   │   ├── components/  
│   │   │   │   ├── neopedia_card.dart  
│   │   │   ├── sections/  
│   │   │   │   ├── clients_projects_section.dart  
│   │   │   │   ├── digital_accelerators_section.dart  
│   │   │   │   ├── history_section.dart  
│   │   │   │   ├── it_challenges_section.dart  
│   │   │   │   ├── values_culture_section.dart  
│   │   ├── quest_catalog/      # Каталог квестов  
│   │   │   ├── adventure/      # Офисный квест  
│   │   │   │   ├── adventure_map_screen.dart  
│   │   │   │   ├── maze_painter.dart  
│   │   │   │   ├── maze_screen.dart  
│   │   │   │   ├── office_map_painter.dart  
│   │   │   ├── neo_coder/      # Кодерский челлендж  
│   │   │   │   ├── neo_coder_data.dart  
│   │   │   │   ├── neo_coder_result.dart  
│   │   │   │   ├── neo_coder_screen.dart  
│   │   │   ├── pair_match/     # Игра на парное соответствие  
│   │   │   │   ├── pair_match_data.dart  
│   │   │   │   ├── pair_match_result.dart  
│   │   │   │   ├── pair_match_screen.dart  
│   │   │   │   ├── pair_match_widgets.dart  
│   │   │   ├── puzzle/         # Пазлы  
│   │   │   │   ├── puzzle_game_widget.dart  
│   │   │   │   ├── puzzle_notifications.dart  
│   │   │   │   ├── puzzle_piece.dart  
│   │   │   │   ├── puzzle_result.dart  
│   │   │   │   ├── puzzle_screen.dart  
│   │   │   │   ├── puzzle_utils.dart  
│   │   │   ├── quiz/           # Викторины  
│   │   │   │   ├── quiz_data.dart  
│   │   │   │   ├── quiz_result.dart  
│   │   │   │   ├── quiz_screen.dart  
│   │   ├── store/              # Игровой магазин  
│   │   │   ├── cart_screen.dart  
│   │   │   ├── cart_tab.dart  
│   │   │   ├── catalog_tab.dart  
│   │   │   ├── image_preview_screen.dart  
│   │   │   ├── main_card.dart  
│   │   │   ├── purchase_history_tab.dart  
│   │   │   ├── top_notification.dart  
│   │   ├── constants.dart  
│   │   ├── daily_task_screen.dart  
│   │   ├── login_screen.dart  
│   │   ├── main_screen.dart  
│   │   ├── neopedia_screen.dart  
│   │   ├── quest_catalog_screen.dart  
│   │   ├── quest_screen.dart  
│   │   ├── register_screen.dart  
│   │   ├── store_screen.dart  
│   │   ├── welcome_screen.dart  
│   ├── widgets/  
│   │   ├── quest_card.dart  
│   ├── main.dart  
│   ├── splash.dart  
├── assets/  
│   ├── images/  
│   │   ├── neocoins.png  
│   │   ├── mascot.jpg  
│   ├── videos/  
├── test/  
├── pubspec.yaml  

# Основные компоненты
- cubits: Управление состоянием через flutter_bloc (аутентификация, квесты, монеты).
- models: Классы данных для задач, прогресса, мерча и пользователей.
- screens: Экраны, организованные по модулям (квесты, магазин, Неопедия).
- assets: Изображения и видео для интерфейса и квестов.
- constants.dart: Глобальные стили (градиенты, цвета).

# Как играть

Войдите или зарегистрируйтесь через экран логина/регистрации.  
Исследуйте Неопедию для знакомства с Neoflex (история, проекты, культура).

Выберите квест в каталоге:
- Neo Coder: Напишите код для анимации маскота.
- Adventure: Исследуйте офис и проходите лабиринты.
- Pair Match: Найдите пары карт.
- Puzzle: Соберите пазлы.
- Quiz: Отвечайте на вопросы.

Выполняйте ежедневные задачи для получения неокоинов.  
Посетите магазин, чтобы купить мерч за неокоины.
