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
      return UserModel(
        uid: map['uid'] as String,
        email: map['email'] as String,
        username: map['username'] as String,
        hasCompletedQuest: map['hasCompletedQuest'] as bool? ?? false,
        questAnswers: List<String?>.from(map['questAnswers'] ?? [null, null, null, null, null]),
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }
}