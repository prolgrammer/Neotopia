import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import '../cubits/auth_cubit.dart';
import 'constants.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showErrorSnackBar(BuildContext context, String message) {
    print('Showing error SnackBar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/neoflex_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        BlocConsumer<AuthCubit, AuthState>(
                          listenWhen: (previous, current) =>
                          (previous.user == null && current.user != null && !current.isLoading) ||
                              (current.error.isNotEmpty && previous.error != current.error),
                          listener: (context, state) {
                            print('AuthState changed: user=${state.user?.uid}, error=${state.error}, isLoading=${state.isLoading}');
                            if (state.user != null) {
                              print('Login successful, navigating');
                              final route = state.user!.hasCompletedQuest ? '/main' : '/quest';
                              Navigator.pushReplacementNamed(context, route);
                            }
                            if (state.error.isNotEmpty) {
                              print('Processing error: ${state.error}');
                              String errorMessage;
                              if (state.error.contains('invalid-credential')) {
                                errorMessage = 'Неправильная почта или пароль';
                              } else if (state.error.contains('invalid-email')) {
                                errorMessage = 'Некорректный email';
                              } else if (state.error.contains('too-many-requests')) {
                                errorMessage = 'Слишком много попыток входа. Попробуйте позже';
                              } else {
                                errorMessage = 'Ошибка при входе';
                              }
                              _showErrorSnackBar(context, errorMessage);
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
                                  _showErrorSnackBar(context, 'Заполните все поля');
                                  return;
                                }
                                if (!EmailValidator.validate(email)) {
                                  _showErrorSnackBar(context, 'Некорректный email');
                                  return;
                                }

                                context.read<AuthCubit>().login(email, password);
                              },
                              child: state.isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text('Войти'),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            print('Navigating to register screen');
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Нет аккаунта? Зарегистрироваться',
                            style: TextStyle(color: Color(0xFF2E0352)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}