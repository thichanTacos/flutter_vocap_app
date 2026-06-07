import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/card/data/card_repository.dart';
import '../../../features/deck/data/deck_repository.dart';
import '../models/vocab_level_deck.dart';
import '../models/vocab_word.dart';
import 'vocab_api_service.dart';

const _cacheKey = 'cefr_words_v1';
const _cacheTimeKey = 'cefr_words_time_v1';
const _cacheTtlDays = 7;
const _wordsPerDeck = 20;

// Thứ tự cấp độ hiển thị
const cefrLevels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

class VocabRepository {
  final VocabApiService _api;
  final DeckRepository _deckRepo;
  final CardRepository _cardRepo;
  final Ref _ref;

  VocabRepository(this._ref)
      : _api = VocabApiService(),
        _deckRepo = DeckRepository(),
        _cardRepo = CardRepository();

  // Trả về Map<level, List<VocabLevelDeck>> chỉ chứa terms (chưa có definition)
  Future<Map<String, List<VocabLevelDeck>>> getLevelDeckMap() async {
    final wordMap = await _getCachedOrFetch();
    final result = <String, List<VocabLevelDeck>>{};

    for (final level in cefrLevels) {
      final words = wordMap[level] ?? [];
      final decks = <VocabLevelDeck>[];
      for (var i = 0; i < words.length; i += _wordsPerDeck) {
        final chunk = words.sublist(
          i,
          (i + _wordsPerDeck).clamp(0, words.length),
        );
        if (chunk.isNotEmpty) {
          decks.add(VocabLevelDeck(
            level: level,
            deckIndex: decks.length,
            terms: chunk,
          ));
        }
      }
      result[level] = decks;
    }
    return result;
  }

  // Fetch definitions cho 20 từ của một deck (parallel)
  Future<List<VocabWord>> fetchDeckDefinitions(VocabLevelDeck deck) async {
    final futures = deck.terms.map((term) => _api.fetchWordDefinition(term, deck.level));
    final results = await Future.wait(futures);
    return results
        .asMap()
        .entries
        .map((e) =>
            e.value ??
            VocabWord(
              term: deck.terms[e.key],
              definition: 'No definition found.',
              level: deck.level,
            ))
        .toList();
  }

  // Import deck vào Firebase library của user hiện tại
  Future<String> importDeckToLibrary(
    List<VocabWord> words,
    String level,
    int deckIndex,
  ) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) throw Exception('Bạn cần đăng nhập để lưu deck');

    final title = '${level.toUpperCase()} – Deck ${deckIndex + 1}';
    final deck = await _deckRepo.createDeck(
      title: title,
      description: 'Từ vựng cấp độ ${level.toUpperCase()} – ${words.length} từ',
      ownerId: user.uid,
    );

    // Add tất cả cards cùng lúc (batch)
    await Future.wait(words.asMap().entries.map((e) => _cardRepo.addCard(
          deckId: deck.id,
          term: e.value.term,
          definition: e.value.definition,
          order: e.key,
        )));

    await _deckRepo.updateCardCount(deck.id, words.length);
    return deck.id;
  }

  // Lấy từ cache SharedPreferences hoặc fetch từ API nếu cache hết hạn
  Future<Map<String, List<String>>> _getCachedOrFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expired = now - cachedTime > _cacheTtlDays * 86400 * 1000;

    if (cachedJson != null && !expired) {
      final raw = json.decode(cachedJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    }

    final fresh = await _api.fetchCefrWordList();
    await prefs.setString(_cacheKey, json.encode(fresh));
    await prefs.setInt(_cacheTimeKey, now);
    return fresh;
  }
}

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  return VocabRepository(ref);
});
