import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import '../cubits/auth_cubit.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

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
        child: Center(
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
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Логин'),
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                        ),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration:
                          InputDecoration(labelText: 'Подтвердите пароль'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state.user != null) {
                              Navigator.pushReplacementNamed(context, '/quest');
                            }
                            if (state.error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error)),
                              );
                            }
                          },
                          builder: (context, state) {
                            return state.isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: () {
                                String email = _emailController.text;
                                String username = _usernameController.text;
                                String password = _passwordController.text;
                                String confirmPassword =
                                    _confirmPasswordController.text;

                                if (email.isEmpty ||
                                    username.isEmpty ||
                                    password.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content:
                                        Text('Заполните все поля')),
                                  );
                                  return;
                                }
                                if (!EmailValidator.validate(email)) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content:
                                        Text('Некорректный email')),
                                  );
                                  return;
                                }
                                if (password.length < 6) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Пароль должен быть не менее 6 символов')),
                                  );
                                  return;
                                }
                                if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Пароли не совпадают')),
                                  );
                                  return;
                                }

                                context.read<AuthCubit>().register(
                                  email,
                                  username,
                                  password,
                                );
                              },
                              child: Text('Зарегистрироваться'),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: Text('Уже есть аккаунт? Войти'),
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