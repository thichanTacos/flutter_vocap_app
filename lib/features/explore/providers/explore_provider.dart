import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocab_repository.dart';
import '../models/vocab_level_deck.dart';
import '../models/vocab_word.dart';

// Provider cho toàn bộ level deck map (cached)
final levelDeckMapProvider =
    FutureProvider<Map<String, List<VocabLevelDeck>>>((ref) {
  return ref.watch(vocabRepositoryProvider).getLevelDeckMap();
});

// Provider fetch definitions cho một deck cụ thể (level, deckIndex)
final deckDefinitionsProvider =
    FutureProvider.family<List<VocabWord>, (String, int)>((ref, params) async {
  final (level, deckIndex) = params;
  final map = await ref.watch(levelDeckMapProvider.future);
  final decks = map[level] ?? [];
  if (deckIndex >= decks.length) return [];
  final deck = decks[deckIndex];
  return ref.watch(vocabRepositoryProvider).fetchDeckDefinitions(deck);
});
