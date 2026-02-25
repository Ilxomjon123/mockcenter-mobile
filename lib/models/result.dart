class ExamResult {
  final int id;
  final String overall;
  final String? listeningScore;
  final String? readingScore;
  final String? writingScore;
  final String? speakingScore;
  final ExamResultExam exam;

  ExamResult({
    required this.id,
    required this.overall,
    this.listeningScore,
    this.readingScore,
    this.writingScore,
    this.speakingScore,
    required this.exam,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as int,
      overall: json['overall']?.toString() ?? '-',
      listeningScore: json['listening_score']?.toString(),
      readingScore: json['reading_score']?.toString(),
      writingScore: json['writing_score']?.toString(),
      speakingScore: json['speaking_score']?.toString(),
      exam: ExamResultExam.fromJson(json['exam'] as Map<String, dynamic>),
    );
  }
}

class ExamResultExam {
  final int id;
  final String type;
  final String datetime;

  ExamResultExam({
    required this.id,
    required this.type,
    required this.datetime,
  });

  factory ExamResultExam.fromJson(Map<String, dynamic> json) {
    return ExamResultExam(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'ielts',
      datetime: json['datetime'] as String? ?? '',
    );
  }
}
