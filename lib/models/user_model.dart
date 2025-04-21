class UserModel {
  final String uid;
  final String email;
  final String username;
  final bool hasCompletedQuest;
  final List<String?> questAnswers;
  final String? avatarUrl;
  final int coins;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.hasCompletedQuest = false,
    this.questAnswers = const [null, null, null, null, null],
    this.avatarUrl,
    this.coins = 0,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      List<String?> questAnswers = List<String?>.filled(5, null);
      final questAnswersData = map['questAnswers'];

      print('Raw questAnswers in fromMap: $questAnswersData');

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
      } else if (questAnswersData != null) {
        print('Warning: questAnswers is not a list or map: $questAnswersData');
      }

      return UserModel(
        uid: map['uid'] as String,
        email: map['email'] as String,
        username: map['username'] as String,
        hasCompletedQuest: map['hasCompletedQuest'] as bool? ?? false,
        questAnswers: questAnswers,
        avatarUrl: map['avatarUrl'] as String?,
        coins: map['coins'] as int? ?? 0,
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }
}