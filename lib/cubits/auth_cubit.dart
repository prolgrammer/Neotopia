import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/daily_task_progress_model.dart';
import 'dart:io';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final UserModel? user;
  final String error;
  final AuthStatus status;

  AuthState({
    this.user,
    this.error = '',
    this.status = AuthStatus.initial,
  });

  AuthState copyWith({
    UserModel? user,
    String? error,
    AuthStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}


class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  AuthCubit() : super(AuthState());

  Future<void> register(String email, String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: ''));
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user');
      }

      UserModel user = UserModel(
        uid: firebaseUser.uid,
        email: email,
        username: username,
        hasCompletedQuest: false,
        questAnswers: List.filled(5, null),
        avatarUrl: null,
        coins: 0,
        purchases: [],
      );

      await _database
          .child('users')
          .child(firebaseUser.uid)
          .set(user.toMap());

      emit(state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
      ));
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
          errorMessage = 'Пароль слишком слабый (минимум 6 символов)';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Регистрация с email/password отключена';
          break;
        default:
          errorMessage = 'Ошибка регистрации: ${e.message}';
      }
      emit(state.copyWith(
        error: errorMessage,
        status: AuthStatus.error,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Неизвестная ошибка: $e',
        status: AuthStatus.error,
      ));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: ''));
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Не удалось войти в систему');
      }

      DataSnapshot snapshot = await _database
          .child('users')
          .child(firebaseUser.uid)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        throw Exception('Данные пользователя не найдены');
      }

      final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> userData = rawData.map((key, value) => MapEntry(key.toString(), value));

      UserModel user = UserModel.fromMap(userData);
      emit(state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
      ));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Пользователь с таким email не найден';
          break;
        case 'wrong-password':
          errorMessage = 'Неверный пароль. Пожалуйста, попробуйте снова';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный формат email';
          break;
        case 'user-disabled':
          errorMessage = 'Этот аккаунт был заблокирован';
          break;
        case 'too-many-requests':
          errorMessage = 'Слишком много попыток входа. Попробуйте позже';
          break;
        case 'invalid-credential':
          errorMessage = 'Неверный email или пароль';
          break;
        default:
          errorMessage = 'Ошибка входа: ${e.message ?? "Неизвестная ошибка"}';
      }
      emit(state.copyWith(
        error: errorMessage,
        status: AuthStatus.error,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Произошла ошибка при входе: ${e.toString()}',
        status: AuthStatus.error,
      ));
    }
  }


  Future<void> saveQuestAnswer(String uid, int questionIndex, String answer) async {
    try {
      print('Saving quest answer for user $uid, question $questionIndex: $answer');
      // Загружаем текущие данные пользователя из базы
      DataSnapshot snapshot = await _database.child('users').child(uid).get();
      List<String?> newAnswers = List.filled(5, null);

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        if (userData['questAnswers'] is List) {
          final List<dynamic> existingAnswers = userData['questAnswers'] as List<dynamic>;
          for (int i = 0; i < existingAnswers.length && i < 5; i++) {
            newAnswers[i] = existingAnswers[i] as String?;
          }
        }
      } else {
        print('No user data found, initializing new questAnswers');
      }

      newAnswers[questionIndex] = answer;

      print('Updating questAnswers in database: $newAnswers');
      await _database.child('users').child(uid).update({
        'questAnswers': newAnswers,
      });

      print('Quest answer saved successfully');
    } catch (e, stackTrace) {
      print('Error saving quest answer: $e\nStackTrace: $stackTrace');
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
      emit(state.copyWith(status: AuthStatus.loading, error: ''));
      final uid = state.user?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      print('Saving avatar locally for user $uid');
      final directory = await getApplicationDocumentsDirectory();
      final avatarPath = '${directory.path}/avatars/$uid.jpg';
      final avatarFile = File(avatarPath);

      await avatarFile.parent.create(recursive: true);
      await File(image.path).copy(avatarPath);

      await _database.child('users').child(uid).update({
        'avatarUrl': avatarPath,
      });

      emit(state.copyWith(
        user: state.user?.copyWith(avatarUrl: avatarPath),
        status: AuthStatus.authenticated,
      ));
      print('Avatar saved locally: $avatarPath');
    } catch (e, stackTrace) {
      print('Error saving avatar: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(
        error: 'Ошибка сохранения аватара: $e',
        status: AuthStatus.error,
      ));
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

  Future<void> addPurchase(String uid, Purchase purchase) async {
    try {
      print('Adding purchase for user $uid: ${purchase.id}');
      final currentPurchases = state.user?.purchases ?? [];
      final updatedPurchases = [...currentPurchases, purchase];

      // Сериализуем покупку
      final purchaseMap = purchase.toMap();
      print('Purchase data to save: $purchaseMap');

      // Сохраняем покупки в базе
      await _database.child('users').child(uid).update({
        'purchases': updatedPurchases.map((p) => p.toMap()).toList(),
      });

      // Проверяем, что данные сохранены
      final snapshot = await _database.child('users').child(uid).child('purchases').get();
      if (snapshot.exists) {
        print('Purchases in database: ${snapshot.value}');
      } else {
        print('No purchases found in database after saving');
      }

      // Обновляем локальное состояние
      emit(state.copyWith(
        user: state.user?.copyWith(purchases: updatedPurchases),
      ));
      print('Purchase added to state');
    } catch (e, stackTrace) {
      print('Error adding purchase: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка добавления покупки: $e'));
    }
  }

  Future<void> completeDailyTask(String uid, String taskId, String date, int rewardCoins) async {
    try {
      print('Completing daily task $taskId for user $uid on date $date');
      final taskProgress = DailyTaskProgress(
        taskId: taskId,
        date: date,
        isCompleted: true,
      );

      await _database
          .child('users')
          .child(uid)
          .child('daily_tasks_progress')
          .child(date)
          .child(taskId)
          .set(taskProgress.toMap());

      final newCoins = (state.user?.coins ?? 0) + rewardCoins;
      await _database.child('users').child(uid).update({
        'coins': newCoins,
      });

      emit(state.copyWith(
        user: state.user?.copyWith(coins: newCoins),
      ));
      print('Daily task $taskId completed, $rewardCoins coins added');
    } catch (e, stackTrace) {
      print('Error completing daily task: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка завершения задания: $e'));
    }
  }

  Future<bool> isDailyTaskCompleted(String uid, String taskId, String date) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(uid)
          .child('daily_tasks_progress')
          .child(date)
          .child(taskId)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final progress = DailyTaskProgress.fromMap(Map<String, dynamic>.from(data));
        return progress.isCompleted;
      }
      return false;
    } catch (e) {
      print('Error checking daily task completion: $e');
      return false;
    }
  }
}

extension on UserModel {
  UserModel copyWith({
    bool? hasCompletedQuest,
    List<String?>? questAnswers,
    String? avatarUrl,
    int? coins,
    List<Purchase>? purchases,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username,
      hasCompletedQuest: hasCompletedQuest ?? this.hasCompletedQuest,
      questAnswers: questAnswers ?? this.questAnswers,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      purchases: purchases ?? this.purchases,
    );
  }
}