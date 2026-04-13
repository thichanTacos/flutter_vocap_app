import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/deck_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/deck_repository.dart';
import '../../card/data/card_repository.dart';

// Stream danh sách deck của user
final userDecksProvider = StreamProvider<List<DeckModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(deckRepositoryProvider).watchUserDecks(user.uid);
});

// Notifier cho CRUD deck
class DeckNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createDeck({
    required String title,
    required String description,
    bool isPublic = false,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Chưa đăng nhập');
      await ref.read(deckRepositoryProvider).createDeck(
        title: title,
        description: description,
        ownerId: user.uid,
        isPublic: isPublic,
      );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateDeck({
    required String deckId,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(deckRepositoryProvider).updateDeck(
        deckId: deckId,
        title: title,
        description: description,
        isPublic: isPublic,
      );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteDeck(String deckId) async {
    state = const AsyncLoading();
    try {
      await ref.read(deckRepositoryProvider).deleteDeck(deckId);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final deckNotifierProvider =
AsyncNotifierProvider<DeckNotifier, void>(DeckNotifier.new);