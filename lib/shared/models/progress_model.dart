class ProgressModel {
  final String deckId;
  final String userId;
  final int learnedCount;    // số thẻ đã học đúng
  final int totalCount;      // tổng số thẻ
  final DateTime lastStudied;

  const ProgressModel({
    required this.deckId,
    required this.userId,
    required this.learnedCount,
    required this.totalCount,
    required this.lastStudied,
  });

  double get percent =>
      totalCount == 0 ? 0 : (learnedCount / totalCount).clamp(0.0, 1.0);

  bool get isCompleted => learnedCount >= totalCount;
  bool get isNotStarted => learnedCount == 0;

  factory ProgressModel.fromMap(Map<String, dynamic> map) => ProgressModel(
    deckId: map['deckId'] as String,
    userId: map['userId'] as String,
    learnedCount: map['learnedCount'] as int? ?? 0,
    totalCount: map['totalCount'] as int? ?? 0,
    lastStudied: DateTime.parse(map['lastStudied'] as String),
  );

  Map<String, dynamic> toMap() => {
    'deckId': deckId,
    'userId': userId,
    'learnedCount': learnedCount,
    'totalCount': totalCount,
    'lastStudied': lastStudied.toIso8601String(),
  };

  ProgressModel copyWith({int? learnedCount, int? totalCount}) =>
      ProgressModel(
        deckId: deckId,
        userId: userId,
        learnedCount: learnedCount ?? this.learnedCount,
        totalCount: totalCount ?? this.totalCount,
        lastStudied: DateTime.now(),
      );
}