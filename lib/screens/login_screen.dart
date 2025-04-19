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
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state.user != null) {
                              if (state.user!.hasCompletedQuest) {
                                Navigator.pushReplacementNamed(
                                    context, '/welcome');
                              } else {
                                Navigator.pushReplacementNamed(
                                    context, '/quest');
                              }
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
                                context.read<AuthCubit>().login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              },
                              child: Text('Войти'),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text('Нет аккаунта? Зарегистрируйтесь'),
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