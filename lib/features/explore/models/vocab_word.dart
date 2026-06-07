class VocabWord {
  final String term;
  final String definition;
  final String? phonetic;
  final String? example;
  final String level;

  const VocabWord({
    required this.term,
    required this.definition,
    this.phonetic,
    this.example,
    required this.level,
  });
}
