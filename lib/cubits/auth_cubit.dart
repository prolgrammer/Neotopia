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
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      print('Starting registration for email: $email');
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        print('Error: FirebaseAuth.currentUser is null');
        throw Exception('Failed to create user');
      }

      print('User created with UID: ${firebaseUser.uid}');
      UserModel user = UserModel(
        uid: firebaseUser.uid,
        email: email,
        username: username,
        hasCompletedQuest: false,
        questAnswers: List.filled(5, null),
      );

      print('Saving user data to Realtime Database: ${user.toMap()}');
      await _database
          .child('users')
          .child(firebaseUser.uid)
          .set(user.toMap());

      print('User data saved successfully');
      emit(state.copyWith(user: user, isLoading: false));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Этот email уже зарегистрирован';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный email';
          break;
        case 'weak-password':
          errorMessage = 'Пароль слишком слабый';
          break;
        default:
          errorMessage = 'Ошибка регистрации: ${e.message}';
      }
      print('FirebaseAuthException: $errorMessage');
      emit(state.copyWith(error: errorMessage, isLoading: false));
    } catch (e, stackTrace) {
      print('Unexpected error during registration: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка регистрации: $e', isLoading: false));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      print('Starting login for email: $email');
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        print('Error: FirebaseAuth.currentUser is null');
        throw Exception('Failed to login user');
      }

      print('User logged in with UID: ${firebaseUser.uid}');
      DataSnapshot snapshot = await _database
          .child('users')
          .child(firebaseUser.uid)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        print('Error: User data not found in Realtime Database');
        throw Exception('Данные пользователя не найдены');
      }

      print('Raw snapshot value: ${snapshot.value}');
      final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> userData = rawData.map((key, value) => MapEntry(key.toString(), value));

      UserModel user = UserModel.fromMap(userData);
      print('User data loaded: ${user.email}');
      emit(state.copyWith(user: user, isLoading: false));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Пользователь не найден';
          break;
        case 'wrong-password':
          errorMessage = 'Неверный пароль';
          break;
        default:
          errorMessage = 'Ошибка входа: ${e.message}';
      }
      print('FirebaseAuthException: $errorMessage');
      emit(state.copyWith(error: errorMessage, isLoading: false));
    } catch (e, stackTrace) {
      print('Unexpected error during login: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> saveQuestAnswer(String uid, int questionIndex, String answer) async {
    try {
      print('Saving quest answer for user $uid, question $questionIndex: $answer');
      // Получаем текущие данные пользователя из базы
      DataSnapshot snapshot = await _database.child('users').child(uid).get();
      List<String?> newAnswers = List.filled(5, null);

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        print('Raw questAnswers: ${userData['questAnswers']}');

        // Проверяем, является ли questAnswers списком
        if (userData['questAnswers'] is List) {
          final List<dynamic> existingAnswers = userData['questAnswers'] as List<dynamic>;
          // Копируем существующие ответы, если они есть
          for (int i = 0; i < existingAnswers.length && i < 5; i++) {
            newAnswers[i] = existingAnswers[i] as String?;
          }
        } else if (userData['questAnswers'] != null) {
          // Если questAnswers не список (например, объект), логируем и используем пустой список
          print('Warning: questAnswers is not a list, resetting to default: ${userData['questAnswers']}');
        }
      } else {
        print('No user data found, initializing new questAnswers');
      }

      // Обновляем ответ для указанного индекса
      newAnswers[questionIndex] = answer;

      // Сохраняем обновленный список в базе
      await _database.child('users').child(uid).update({
        'questAnswers': newAnswers,
      });

      // Обновляем состояние
      emit(state.copyWith(
        user: state.user?.copyWith(questAnswers: newAnswers),
      ));
      print('Quest answer saved successfully');
    } catch (e, stackTrace) {
      print('Error saving quest answer: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка сохранения ответа: $e'));
    }
  }

  Future<void> completeQuest(String uid) async {
    try {
      print('Completing quest for user $uid');
      await _database.child('users').child(uid).update({
        'hasCompletedQuest': true,
      });
      emit(state.copyWith(
        user: state.user?.copyWith(hasCompletedQuest: true),
      ));
      print('Quest completed');
    } catch (e, stackTrace) {
      print('Error completing quest: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка завершения квеста: $e'));
    }
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