import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import 'constants.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите email';
    }
    if (!EmailValidator.validate(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/neoflex_logo.png',
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(labelText: 'Пароль'),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          BlocConsumer<AuthCubit, AuthState>(
                            listenWhen: (previous, current) =>
                            previous.status != current.status,
                            listener: (context, state) {
                              if (state.status == AuthStatus.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _buildErrorSnackBar(state.error),
                                );
                              }
                              if (state.status == AuthStatus.authenticated) {
                                final route = state.user!.hasCompletedQuest
                                    ? '/main'
                                    : '/quest';
                                Navigator.pushReplacementNamed(context, route);
                              }
                            },
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.status == AuthStatus.loading
                                    ? null
                                    : () {
                                  String? emailError = _validateEmail(_emailController.text);
                                  String? passwordError = _validatePassword(_passwordController.text);

                                  if (emailError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      _buildErrorSnackBar(emailError),
                                    );
                                    return;
                                  }
                                  if (passwordError != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      _buildErrorSnackBar(passwordError),
                                    );
                                    return;
                                  }

                                  context.read<AuthCubit>().login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                },
                                child: state.status == AuthStatus.loading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                                    : Text(
                                  'Войти',
                                  style: TextStyle(color: Color(0xFF140032)),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Нет аккаунта? Зарегистрироваться',
                              style: TextStyle(color: Color(0xFF140032)),
                            ),
                          ),
                        ],
                      ),
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

  SnackBar _buildErrorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(20),
    );
  }
}