import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              right: 16,
              child: Image.asset(
                'assets/images/mascot.jpg',
                height: 100,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/neoflex_logo.jpg',
                      height: 100,
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: 'Пароль'),
                              obscureText: true,
                            ),
                            SizedBox(height: 16),
                            BlocConsumer<AuthCubit, AuthState>(
                              listener: (context, state) {
                                print('AuthState changed: user=${state.user}, error=${state.error}, isLoading=${state.isLoading}');
                                if (state.user != null) {
                                  print('Navigating after login');
                                  final route = state.user!.hasCompletedQuest ? '/main' : '/quest';
                                  Navigator.pushReplacementNamed(context, route);
                                }
                                if (state.error.isNotEmpty) {
                                  print('Showing error: ${state.error}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.error)),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                    String email = _emailController.text.trim();
                                    String password = _passwordController.text;

                                    print('Login button pressed: email=$email');
                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Заполните все поля')),
                                      );
                                      return;
                                    }

                                    context.read<AuthCubit>().login(email, password);
                                  },
                                  child: state.isLoading
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : Text('Войти'),
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                print('Navigating to register screen');
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text('Нет аккаунта? Зарегистрироваться'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}