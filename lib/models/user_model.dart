import 'merch_model.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final bool hasCompletedQuest;
  final List<String?> questAnswers;
  final String? avatarUrl;
  final int coins;
  final List<Purchase>? purchases;
  final Map<String, List<String>> dailyTasksProgress; // Хранит выполненные задания по датам

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.hasCompletedQuest = false,
    this.questAnswers = const [null, null, null, null, null],
    this.avatarUrl,
    this.coins = 0,
    this.purchases,
    this.dailyTasksProgress = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'hasCompletedQuest': hasCompletedQuest,
      'questAnswers': questAnswers,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'purchases': purchases?.map((purchase) => purchase.toMap()).toList(),
      'dailyTasksProgress': dailyTasksProgress,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      List<String?> questAnswers = List<String?>.filled(5, null);
      final questAnswersData = map['questAnswers'];

      if (questAnswersData is List) {
        for (int i = 0; i < questAnswersData.length && i < 5; i++) {
          questAnswers[i] = questAnswersData[i] as String?;
        }
      } else if (questAnswersData is Map) {
        final Map<dynamic, dynamic> answersMap = questAnswersData;
        answersMap.forEach((key, value) {
          final index = int.tryParse(key.toString());
          if (index != null && index >= 0 && index < 5) {
            questAnswers[index] = value as String?;
          }
        });
      }

      List<Purchase>? purchases;
      final purchasesData = map['purchases'];
      if (purchasesData is List) {
        purchases = purchasesData
            .map((purchase) => Purchase.fromMap(Map<String, dynamic>.from(purchase)))
            .toList();
      } else if (purchasesData is Map) {
        purchases = purchasesData.entries
            .map((entry) => Purchase.fromMap(Map<String, dynamic>.from(entry.value)))
            .toList();
      }

      Map<String, List<String>> dailyTasksProgress = {};
      final dailyTasksProgressData = map['dailyTasksProgress'];
      if (dailyTasksProgressData is Map) {
        dailyTasksProgress = dailyTasksProgressData.map((key, value) => MapEntry(
          key.toString(),
          (value is List) ? value.cast<String>() : [],
        ));
      }

      return UserModel(
        uid: map['uid'] as String,
        email: map['email'] as String,
        username: map['username'] as String,
        hasCompletedQuest: map['hasCompletedQuest'] as bool? ?? false,
        questAnswers: questAnswers,
        avatarUrl: map['avatarUrl'] as String?,
        coins: map['coins'] as int? ?? 0,
        purchases: purchases,
        dailyTasksProgress: dailyTasksProgress,
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }
}

class Purchase {
  final String id;
  final List<MerchItem> items;
  final int totalPrice;
  final String timestamp;
  final String status;

  Purchase({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'timestamp': timestamp,
      'status': status,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] as String,
      items: (map['items'] as List<dynamic>)
          .map((item) => MerchItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      totalPrice: map['totalPrice'] as int,
      timestamp: map['timestamp'] as String,
      status: map['status'] as String,
    );
  }
}