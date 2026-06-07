class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String? lastStudyDate; // "yyyy-MM-dd"
  final List<String> studiedDates;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.studiedDates = const [],
  });

  bool studiedOn(DateTime date) => studiedDates.contains(dateKey(date));

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  factory StreakModel.fromMap(Map<String, dynamic> map) => StreakModel(
        currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
        lastStudyDate: map['lastStudyDate'] as String?,
        studiedDates:
            List<String>.from(map['studiedDates'] as List? ?? const []),
      );

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastStudyDate': lastStudyDate,
        'studiedDates': studiedDates,
      };
}
