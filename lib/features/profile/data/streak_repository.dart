import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'streak_model.dart';

class StreakRepository {
  final FirebaseFirestore _firestore;

  StreakRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('streaks').doc(userId);

  Stream<StreakModel> watchStreak(String userId) =>
      _doc(userId).snapshots().map((snap) => snap.exists
          ? StreakModel.fromMap(snap.data()!)
          : const StreakModel());

  Future<void> recordStudyDay(String userId) async {
    final today = StreakModel.dateKey(DateTime.now());
    final yesterday =
        StreakModel.dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final cutoff =
        StreakModel.dateKey(DateTime.now().subtract(const Duration(days: 90)));
    final docRef = _doc(userId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final current = snap.exists
          ? StreakModel.fromMap(snap.data()!)
          : const StreakModel();

      // Already recorded today — nothing to update
      if (current.lastStudyDate == today) return;

      final newStreak = current.lastStudyDate == yesterday
          ? current.currentStreak + 1
          : 1;

      final newLongest =
          newStreak > current.longestStreak ? newStreak : current.longestStreak;

      final newDates = [...current.studiedDates, today]
          .where((d) => d.compareTo(cutoff) >= 0)
          .toList();

      tx.set(docRef, {
        'currentStreak': newStreak,
        'longestStreak': newLongest,
        'lastStudyDate': today,
        'studiedDates': newDates,
      });
    });
  }
}

final streakRepositoryProvider =
    Provider<StreakRepository>((ref) => StreakRepository());
