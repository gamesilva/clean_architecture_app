import 'package:equatable/equatable.dart';

class SurveyViewModel extends Equatable {
  final String id;
  final String question;
  final String date;
  final bool didAnswer;

  @override
  List<Object?> get props => [id, question, date, didAnswer];

  SurveyViewModel({
    required this.id,
    required this.question,
    required this.date,
    required this.didAnswer,
  });
}
