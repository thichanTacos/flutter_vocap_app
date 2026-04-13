class DeckModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final bool isPublic;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    this.isPublic = false,
    this.cardCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckModel.fromMap(Map<String, dynamic> map, String id) => DeckModel(
    id: id,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    ownerId: map['ownerId'] as String,
    isPublic: map['isPublic'] as bool? ?? false,
    cardCount: map['cardCount'] as int? ?? 0,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'ownerId': ownerId,
    'isPublic': isPublic,
    'cardCount': cardCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  DeckModel copyWith({
    String? title,
    String? description,
    bool? isPublic,
    int? cardCount,
    DateTime? updatedAt,
  }) =>
      DeckModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        ownerId: ownerId,
        isPublic: isPublic ?? this.isPublic,
        cardCount: cardCount ?? this.cardCount,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}