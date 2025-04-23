import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neotopia/screens/daily_task_screen.dart';
import 'package:neotopia/screens/main_screen.dart';
import 'package:neotopia/screens/neopedia_screen.dart';
import 'package:neotopia/screens/store_screen.dart';
import 'package:neotopia/splash.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/quest_catalog_screen.dart';
import 'screens/quest_catalog/adventure/adventure_map_screen.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/game_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NeoflexGame());
}

class NeoflexGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) => GameCubit(authCubit: context.read<AuthCubit>()),
        ),
      ],
      child: MaterialApp(
        title: 'Neoflex Game',
        theme: ThemeData(
          primaryColor: Colors.purple,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/quest': (context) => QuestScreen(),
          '/welcome': (context) => WelcomeScreen(),
          '/main': (context) => MainScreen(),
          '/quest_catalog': (context) => QuestCatalogScreen(),
          '/neopedia': (context) => NeopediaScreen(),
          '/store': (context) => StoreScreen(),
          '/adventure_map': (context) => AdventureMapScreen(),
          '/daily_tasks': (context) => DailyTasksScreen(),
        },
      ),
    );
  }
}