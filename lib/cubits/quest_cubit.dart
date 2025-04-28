import 'package:flutter_bloc/flutter_bloc.dart';

class QuestState {
  final int currentQuestionIndex;
  final List<String?> answers;
  final bool isCompleted;

  QuestState({
    this.currentQuestionIndex = 0,
    this.answers = const [null, null, null, null, null],
    this.isCompleted = false,
  });

  QuestState copyWith({
    int? currentQuestionIndex,
    List<String?>? answers,
    bool? isCompleted,
  }) {
    return QuestState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuestCubit extends Cubit<QuestState> {
  QuestCubit({int initialIndex = 0}) : super(QuestState(currentQuestionIndex: initialIndex));

  void answerQuestion(String answer, {required Function(int, String) onSave}) {
    print('QuestCubit: Saving answer for question ${state.currentQuestionIndex}: $answer');
    List<String?> newAnswers = List.from(state.answers);
    newAnswers[state.currentQuestionIndex] = answer;
    int nextIndex = state.currentQuestionIndex + 1;
    bool isCompleted = nextIndex >= 5;

    onSave(state.currentQuestionIndex, answer);

    emit(state.copyWith(
      answers: newAnswers,
      currentQuestionIndex: isCompleted ? state.currentQuestionIndex : nextIndex,
      isCompleted: isCompleted,
    ));
  }
}