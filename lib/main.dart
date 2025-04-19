import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/welcome_screen.dart';
import 'cubits/auth_cubit.dart';

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
      ],
      child: MaterialApp(
        title: 'Neoflex Game',
        theme: ThemeData(
          primaryColor: Colors.purple,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/quest': (context) => QuestScreen(),
          '/welcome': (context) => WelcomeScreen(),
        },
      ),
    );
  }
}