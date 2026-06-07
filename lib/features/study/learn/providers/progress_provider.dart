import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/progress_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/data/streak_repository.dart';
import '../data/progress_repository.dart';

final userProgressProvider =
StreamProvider<List<ProgressModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref
      .watch(progressRepositoryProvider)
      .watchUserProgress(user.uid);
});

final deckProgressProvider =
FutureProvider.family<ProgressModel?, String>((ref, deckId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref
      .read(progressRepositoryProvider)
      .getProgress(user.uid, deckId);
});

class ProgressNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveProgress({
    required String deckId,
    required int learnedCount,
    required int totalCount,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final progress = ProgressModel(
      deckId: deckId,
      userId: user.uid,
      learnedCount: learnedCount,
      totalCount: totalCount,
      lastStudied: DateTime.now(),
    );
    await ref.read(progressRepositoryProvider).saveProgress(progress);
    await ref.read(streakRepositoryProvider).recordStudyDay(user.uid);
  }
}

final progressNotifierProvider =
AsyncNotifierProvider<ProgressNotifier, void>(ProgressNotifier.new);