import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/card_model.dart';

class CardRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _cards => _firestore.collection('cards');

  // Lấy danh sách cards theo deck
  Stream<List<CardModel>> watchCards(String deckId) {
    return _cards
        .where('deckId', isEqualTo: deckId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        CardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // Thêm card mới
  Future<CardModel> addCard({
    required String deckId,
    required String term,
    required String definition,
    required int order,
  }) async {
    final id = _uuid.v4();
    final card = CardModel(
      id: id,
      deckId: deckId,
      term: term,
      definition: definition,
      order: order,
      createdAt: DateTime.now(),
    );
    await _cards.doc(id).set(card.toMap());
    return card;
  }

  // Cập nhật card
  Future<void> updateCard({
    required String cardId,
    required String term,
    required String definition,
  }) async {
    await _cards.doc(cardId).update({
      'term': term,
      'definition': definition,
    });
  }

  // Xoá card
  Future<void> deleteCard(String cardId) async {
    await _cards.doc(cardId).delete();
  }

  // Lấy số lượng cards
  Future<int> getCardCount(String deckId) async {
    final snapshot = await _cards
        .where('deckId', isEqualTo: deckId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}

final cardRepositoryProvider = Provider<CardRepository>(
      (ref) => CardRepository(),
);