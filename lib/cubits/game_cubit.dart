import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';

class GameState {
  final int coins;

  GameState({required this.coins});

  GameState copyWith({int? coins}) {
    return GameState(coins: coins ?? this.coins);
  }
}

class GameCubit extends Cubit<void> {
  final AuthCubit authCubit;

  GameCubit({required this.authCubit}) : super(null);

  Future<void> addCoins(int points) async {
    final user = authCubit.state.user;
    if (user != null) {
      final newCoins = user.coins + points;
      await authCubit.updateCoins(user.uid, newCoins);
    }
  }
}