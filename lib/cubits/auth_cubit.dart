import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final String error;
  final bool isLoading;

  AuthState({
    this.user,
    this.error = '',
    this.isLoading = false,
  });

  AuthState copyWith({UserModel? user, String? error, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  AuthCubit() : super(AuthState());

  Future<void> register(String email, String username, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserModel user = UserModel(
        uid: credential.user!.uid,
        email: email,
        username: username,
      );
      await _database
          .child('users')
          .child(credential.user!.uid)
          .set(user.toMap());
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DataSnapshot snapshot = await _database
          .child('users')
          .child(credential.user!.uid)
          .get();

      // Проверяем, что snapshot.value не null и является Map
      if (snapshot.value == null) {
        throw Exception('User data not found');
      }

      // Приводим snapshot.value к Map<String, dynamic>
      final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> userData = rawData.map((key, value) => MapEntry(key.toString(), value));

      UserModel user = UserModel.fromMap(userData);
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> saveQuestAnswer(String uid, int questionIndex, String answer) async {
    List<String?> newAnswers = List.from(state.user?.questAnswers ?? [null, null, null, null, null]);
    newAnswers[questionIndex] = answer;
    await _database.child('users').child(uid).update({
      'questAnswers': newAnswers,
    });
    emit(state.copyWith(
      user: state.user?.copyWith(questAnswers: newAnswers),
    ));
  }

  Future<void> completeQuest(String uid) async {
    await _database.child('users').child(uid).update({
      'hasCompletedQuest': true,
    });
    emit(state.copyWith(
      user: state.user?.copyWith(hasCompletedQuest: true),
    ));
  }
}

extension on UserModel {
  UserModel copyWith({bool? hasCompletedQuest, List<String?>? questAnswers}) {
    return UserModel(
      uid: uid,
      email: email,
      username: username,
      hasCompletedQuest: hasCompletedQuest ?? this.hasCompletedQuest,
      questAnswers: questAnswers ?? this.questAnswers,
    );
  }
}