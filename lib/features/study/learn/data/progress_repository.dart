import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ProgressModel>> watchUserProgress(String userId) {
    return _firestore
        .collection('progress')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ProgressModel.fromMap(doc.data()))
        .toList());
  }

  Future<ProgressModel?> getProgress(String userId, String deckId) async {
    final doc = await _firestore
        .collection('progress')
        .doc('${userId}_$deckId')
        .get();
    if (!doc.exists) return null;
    return ProgressModel.fromMap(doc.data()!);
  }

  Future<void> saveProgress(ProgressModel progress) async {
    await _firestore
        .collection('progress')
        .doc('${progress.userId}_${progress.deckId}')
        .set(progress.toMap());
  }

  Future<void> deleteProgress(String userId, String deckId) async {
    await _firestore
        .collection('progress')
        .doc('${userId}_$deckId')
        .delete();
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
      (ref) => ProgressRepository(),
);