class UserModel {
  final String uid;
  final String email;
  final String username;
  final bool hasCompletedQuest;
  final List<String?> questAnswers;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.hasCompletedQuest = false,
    this.questAnswers = const [null, null, null, null, null],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'hasCompletedQuest': hasCompletedQuest,
      'questAnswers': questAnswers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      List<String?> questAnswers = List<String?>.filled(5, null);
      final questAnswersData = map['questAnswers'];

      print('Raw questAnswers in fromMap: $questAnswersData');

      if (questAnswersData is List) {
        // Если questAnswers - список
        for (int i = 0; i < questAnswersData.length && i < 5; i++) {
          questAnswers[i] = questAnswersData[i] as String?;
        }
      } else if (questAnswersData is Map) {
        // Если questAnswers - объект (например, {0: "answer"})
        final Map<dynamic, dynamic> answersMap = questAnswersData;
        answersMap.forEach((key, value) {
          final index = int.tryParse(key.toString());
          if (index != null && index >= 0 && index < 5) {
            questAnswers[index] = value as String?;
          }
        });
      } else if (questAnswersData != null) {
        // Если questAnswers - другой тип
        print('Warning: questAnswers is not a list or map: $questAnswersData');
      }

      return UserModel(
        uid: map['uid'] as String,
        email: map['email'] as String,
        username: map['username'] as String,
        hasCompletedQuest: map['hasCompletedQuest'] as bool? ?? false,
        questAnswers: questAnswers,
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }
}