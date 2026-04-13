import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/card_model.dart';
import '../data/card_repository.dart';
import '../../deck/data/deck_repository.dart';

// Stream cards theo deckId
final deckCardsProvider =
StreamProvider.family<List<CardModel>, String>((ref, deckId) {
  return ref.watch(cardRepositoryProvider).watchCards(deckId);
});

class CardNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> addCard({
    required String deckId,
    required String term,
    required String definition,
    required int order,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(cardRepositoryProvider).addCard(
        deckId: deckId,
        term: term,
        definition: definition,
        order: order,
      );
      // Cập nhật cardCount trong deck
      final count =
      await ref.read(cardRepositoryProvider).getCardCount(deckId);
      await ref.read(deckRepositoryProvider).updateCardCount(deckId, count);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateCard({
    required String cardId,
    required String term,
    required String definition,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(cardRepositoryProvider).updateCard(
        cardId: cardId,
        term: term,
        definition: definition,
      );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteCard({
    required String cardId,
    required String deckId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(cardRepositoryProvider).deleteCard(cardId);
      final count =
      await ref.read(cardRepositoryProvider).getCardCount(deckId);
      await ref.read(deckRepositoryProvider).updateCardCount(deckId, count);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final cardNotifierProvider =
AsyncNotifierProvider<CardNotifier, void>(CardNotifier.new);