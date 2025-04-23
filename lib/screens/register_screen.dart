import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import '../cubits/auth_cubit.dart';
import 'constants.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  void _showSuccessSnackBar(BuildContext context) {
    print('Showing success SnackBar');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Expanded(
              child: Text(
                'Регистрация успешна!',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Image.asset(
              'assets/images/neocoins.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
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
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Логин'),
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                        ),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        BlocConsumer<AuthCubit, AuthState>(
                          listenWhen: (previous, current) =>
                          (previous.user == null && current.user != null && !current.isLoading) ||
                              (current.error.isNotEmpty &&
                                  previous.error != current.error &&
                                  (current.error.contains('email-already-in-use') ||
                                      current.error.contains('weak-password') ||
                                      current.error.contains('invalid-email') ||
                                      current.error.contains('username-already-exists'))),
                          listener: (context, state) {
                            print('AuthState changed: user=${state.user?.uid}, error=${state.error}, isLoading=${state.isLoading}');
                            if (state.user != null) {
                              print('Registration successful, showing success SnackBar');
                              _showSuccessSnackBar(context);
                              print('Navigating to quest screen after delay');
                              Future.delayed(const Duration(milliseconds: 500), () {
                                Navigator.pushReplacementNamed(context, '/quest');
                              });
                            }
                            if (state.error.isNotEmpty) {
                              print('Processing error: ${state.error}');
                              String errorMessage;
                              if (state.error.contains('email-already-in-use')) {
                                errorMessage = 'Эта почта уже зарегистрирована';
                              } else if (state.error.contains('weak-password')) {
                                errorMessage = 'Пароль слишком слабый';
                              } else if (state.error.contains('invalid-email')) {
                                errorMessage = 'Некорректный email';
                              } else if (state.error.contains('username-already-exists')) {
                                errorMessage = 'Этот логин уже занят';
                              } else {
                                errorMessage = 'Ошибка при регистрации';
                              }
                              _showErrorSnackBar(context, errorMessage);
                            }
                          },
                          builder: (context, state) {
                            return state.isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: () {
                                String email = _emailController.text.trim();
                                String username = _usernameController.text.trim();
                                String password = _passwordController.text;
                                String confirmPassword = _confirmPasswordController.text;

                                print('Register button pressed: email=$email, username=$username');
                                if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                                  _showErrorSnackBar(context, 'Заполните все поля');
                                  return;
                                }
                                if (!EmailValidator.validate(email)) {
                                  _showErrorSnackBar(context, 'Некорректный email');
                                  return;
                                }
                                if (password.length < 6) {
                                  _showErrorSnackBar(context, 'Пароль должен быть не менее 6 символов');
                                  return;
                                }
                                if (password != confirmPassword) {
                                  _showErrorSnackBar(context, 'Пароли не совпадают');
                                  return;
                                }

                                context.read<AuthCubit>().register(
                                  email,
                                  username,
                                  password,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E0352),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Зарегистрироваться',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            print('Navigating to login screen');
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Уже есть аккаунт? Войти',
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