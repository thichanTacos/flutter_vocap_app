class FolderModel {
  final String id;
  final String title;
  final String ownerId;
  final List<String> deckIds;
  final DateTime createdAt;

  const FolderModel({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.deckIds,
    required this.createdAt,
  });

  factory FolderModel.fromMap(Map<String, dynamic> map, String id) =>
      FolderModel(
        id: id,
        title: map['title'] as String,
        ownerId: map['ownerId'] as String,
        deckIds: List<String>.from(map['deckIds'] ?? []),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'ownerId': ownerId,
    'deckIds': deckIds,
    'createdAt': createdAt.toIso8601String(),
  };

  FolderModel copyWith({String? title, List<String>? deckIds}) =>
      FolderModel(
        id: id,
        title: title ?? this.title,
        ownerId: ownerId,
        deckIds: deckIds ?? this.deckIds,
        createdAt: createdAt,
      );
}