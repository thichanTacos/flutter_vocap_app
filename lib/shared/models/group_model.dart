class GroupModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final List<String> deckIds;
  final String inviteCode;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.deckIds,
    required this.inviteCode,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) =>
      GroupModel(
        id: id,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        ownerId: map['ownerId'] as String,
        memberIds: List<String>.from(map['memberIds'] ?? []),
        deckIds: List<String>.from(map['deckIds'] ?? []),
        inviteCode: map['inviteCode'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'deckIds': deckIds,
    'inviteCode': inviteCode,
    'createdAt': createdAt.toIso8601String(),
  };
}