import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import 'dart:io';

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
        avatarUrl: null,
        coins: 0,
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
      DataSnapshot snapshot = await _database.child('users').child(uid).get();
      List<String?> newAnswers = List.filled(5, null);

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        print('Raw questAnswers: ${userData['questAnswers']}');

        if (userData['questAnswers'] is List) {
          final List<dynamic> existingAnswers = userData['questAnswers'] as List<dynamic>;
          for (int i = 0; i < existingAnswers.length && i < 5; i++) {
            newAnswers[i] = existingAnswers[i] as String?;
          }
        } else if (userData['questAnswers'] != null) {
          print('Warning: questAnswers is not a list, resetting to default: ${userData['questAnswers']}');
        }
      } else {
        print('No user data found, initializing new questAnswers');
      }

      newAnswers[questionIndex] = answer;

      await _database.child('users').child(uid).update({
        'questAnswers': newAnswers,
      });

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
        'coins': (state.user?.coins ?? 0) + 50,
      });
      emit(state.copyWith(
        user: state.user?.copyWith(
          hasCompletedQuest: true,
          coins: (state.user?.coins ?? 0) + 50,
        ),
      ));
      print('Quest completed');
    } catch (e, stackTrace) {
      print('Error completing quest: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка завершения квеста: $e'));
    }
  }

  Future<void> uploadAvatar(XFile image) async {
    try {
      emit(state.copyWith(isLoading: true, error: ''));
      final uid = state.user?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      print('Saving avatar locally for user $uid');
      final directory = await getApplicationDocumentsDirectory();
      final avatarPath = '${directory.path}/avatars/$uid.jpg';
      final avatarFile = File(avatarPath);

      // Создаём директорию, если она не существует
      await avatarFile.parent.create(recursive: true);
      // Копируем изображение
      await File(image.path).copy(avatarPath);

      // Сохраняем путь в базе
      await _database.child('users').child(uid).update({
        'avatarUrl': avatarPath,
      });

      emit(state.copyWith(
        user: state.user?.copyWith(avatarUrl: avatarPath),
        isLoading: false,
      ));
      print('Avatar saved locally: $avatarPath');
    } catch (e, stackTrace) {
      print('Error saving avatar: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка сохранения аватара: $e', isLoading: false));
    }
  }

  Future<void> updateCoins(String uid, int newCoins) async {
    try {
      print('Updating coins for user $uid: $newCoins');
      await _database.child('users').child(uid).update({
        'coins': newCoins,
      });
      emit(state.copyWith(
        user: state.user?.copyWith(coins: newCoins),
      ));
      print('Coins updated');
    } catch (e, stackTrace) {
      print('Error updating coins: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка обновления монет: $e'));
    }
  }
}

extension on UserModel {
  UserModel copyWith({
    bool? hasCompletedQuest,
    List<String?>? questAnswers,
    String? avatarUrl,
    int? coins,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username,
      hasCompletedQuest: hasCompletedQuest ?? this.hasCompletedQuest,
      questAnswers: questAnswers ?? this.questAnswers,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
    );
  }
}