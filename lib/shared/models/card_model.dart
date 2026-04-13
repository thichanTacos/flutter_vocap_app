class CardModel {
  final String id;
  final String deckId;
  final String term;
  final String definition;
  final String? imageUrl;
  final int order;
  final DateTime createdAt;

  const CardModel({
    required this.id,
    required this.deckId,
    required this.term,
    required this.definition,
    this.imageUrl,
    this.order = 0,
    required this.createdAt,
  });

  factory CardModel.fromMap(Map<String, dynamic> map, String id) => CardModel(
    id: id,
    deckId: map['deckId'] as String,
    term: map['term'] as String,
    definition: map['definition'] as String,
    imageUrl: map['imageUrl'] as String?,
    order: map['order'] as int? ?? 0,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  Map<String, dynamic> toMap() => {
    'deckId': deckId,
    'term': term,
    'definition': definition,
    'imageUrl': imageUrl,
    'order': order,
    'createdAt': createdAt.toIso8601String(),
  };

  CardModel copyWith({
    String? term,
    String? definition,
    String? imageUrl,
    int? order,
  }) =>
      CardModel(
        id: id,
        deckId: deckId,
        term: term ?? this.term,
        definition: definition ?? this.definition,
        imageUrl: imageUrl ?? this.imageUrl,
        order: order ?? this.order,
        createdAt: createdAt,
      );
}