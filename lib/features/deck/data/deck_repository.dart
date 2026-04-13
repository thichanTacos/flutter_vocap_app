import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/deck_model.dart';

class DeckRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  DeckRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _decks => _firestore.collection('decks');

  // Lấy danh sách deck của user
  Stream<List<DeckModel>> watchUserDecks(String userId) {
    return _decks
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        DeckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Lấy 1 deck theo id
  Future<DeckModel> getDeck(String deckId) async {
    final doc = await _decks.doc(deckId).get();
    return DeckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Tạo deck mới
  Future<DeckModel> createDeck({
    required String title,
    required String description,
    required String ownerId,
    bool isPublic = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final deck = DeckModel(
      id: id,
      title: title,
      description: description,
      ownerId: ownerId,
      isPublic: isPublic,
      createdAt: now,
      updatedAt: now,
    );
    await _decks.doc(id).set(deck.toMap());
    return deck;
  }

  // Cập nhật deck
  Future<void> updateDeck({
    required String deckId,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    await _decks.doc(deckId).update({
      'title': title,
      'description': description,
      'isPublic': isPublic,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Xoá deck
  Future<void> deleteDeck(String deckId) async {
    // Xoá tất cả cards trong deck trước
    final cards = await _firestore
        .collection('cards')
        .where('deckId', isEqualTo: deckId)
        .get();
    final batch = _firestore.batch();
    for (final doc in cards.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_decks.doc(deckId));
    await batch.commit();
  }

  // Lấy nhiều deck theo danh sách id
  Future<List<DeckModel>> getDecksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => _decks.doc(id).get());
    final docs = await Future.wait(futures);
    return docs
        .where((doc) => doc.exists)
        .map((doc) =>
        DeckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Cập nhật số lượng card
  Future<void> updateCardCount(String deckId, int count) async {
    await _decks.doc(deckId).update({'cardCount': count});
  }
}

final deckRepositoryProvider = Provider<DeckRepository>(
      (ref) => DeckRepository(),
);