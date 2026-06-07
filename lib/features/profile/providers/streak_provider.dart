import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/streak_model.dart';
import '../data/streak_repository.dart';

export '../data/streak_model.dart';
export '../data/streak_repository.dart';

final userStreakProvider = StreamProvider<StreakModel>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const StreakModel());
  return ref.watch(streakRepositoryProvider).watchStreak(user.uid);
});
