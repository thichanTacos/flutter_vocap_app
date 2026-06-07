import 'vocab_word.dart';

class VocabLevelDeck {
  final String level;
  final int deckIndex;
  final List<String> terms;
  final List<VocabWord>? words;

  const VocabLevelDeck({
    required this.level,
    required this.deckIndex,
    required this.terms,
    this.words,
  });

  String get displayName => '${level.toUpperCase()} – Deck ${deckIndex + 1}';

  VocabLevelDeck copyWith({List<VocabWord>? words}) => VocabLevelDeck(
        level: level,
        deckIndex: deckIndex,
        terms: terms,
        words: words ?? this.words,
      );
}
