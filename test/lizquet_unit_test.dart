import 'package:flutter_test/flutter_test.dart';
import 'package:quizlet_clone/shared/models/progress_model.dart';
import 'package:quizlet_clone/shared/models/card_model.dart';

void main() {
  // ================================================================
  // GROUP 1: ProgressModel
  // Phụ trách: Thành viên 3
  // ================================================================
  group('ProgressModel', () {
    test('percent returns 0.0 when no cards learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 0,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.percent, 0.0);
    });

    test('percent returns 1.0 when all cards learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 10,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.percent, 1.0);
    });

    test('percent returns 0.5 when half cards learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 5,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.percent, 0.5);
    });

    test('percent returns 0.0 when totalCount is zero', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 0,
        totalCount: 0,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.percent, 0.0);
    });

    test('isCompleted returns true when all cards learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 10,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.isCompleted, true);
    });

    test('isCompleted returns false when partially learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 5,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.isCompleted, false);
    });

    test('isNotStarted returns true when learnedCount is zero', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 0,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.isNotStarted, true);
    });

    test('isNotStarted returns false when some cards learned', () {
      final progress = ProgressModel(
        deckId: 'deck-001',
        userId: 'user-001',
        learnedCount: 3,
        totalCount: 10,
        lastStudied: DateTime(2024, 1, 1),
      );
      expect(progress.isNotStarted, false);
    });

    test('fromMap and toMap round-trip preserves all fields', () {
      final original = ProgressModel(
        deckId: 'deck-roundtrip',
        userId: 'user-roundtrip',
        learnedCount: 7,
        totalCount: 15,
        lastStudied: DateTime(2024, 6, 15),
      );
      final map = original.toMap();
      final restored = ProgressModel.fromMap(map);
      expect(restored.deckId, original.deckId);
      expect(restored.userId, original.userId);
      expect(restored.learnedCount, original.learnedCount);
      expect(restored.totalCount, original.totalCount);
    });
  });

  // ================================================================
  // GROUP 2: CardModel
  // Phụ trách: Thành viên 4
  // ================================================================
  group('CardModel', () {
    test('fromMap creates CardModel with correct fields', () {
      final map = {
        'deckId': 'deck-001',
        'term': 'apple',
        'definition': 'quả táo',
        'imageUrl': null,
        'order': 0,
        'createdAt': '2024-01-01T00:00:00.000',
      };
      final card = CardModel.fromMap(map, 'card-001');
      expect(card.id, 'card-001');
      expect(card.deckId, 'deck-001');
      expect(card.term, 'apple');
      expect(card.definition, 'quả táo');
      expect(card.order, 0);
    });

    test('toMap returns correct map with all fields', () {
      final card = CardModel(
        id: 'card-001',
        deckId: 'deck-001',
        term: 'book',
        definition: 'cuốn sách',
        order: 1,
        createdAt: DateTime(2024, 3, 10),
      );
      final map = card.toMap();
      expect(map['deckId'], 'deck-001');
      expect(map['term'], 'book');
      expect(map['definition'], 'cuốn sách');
      expect(map['order'], 1);
    });

    test('fromMap toMap round-trip preserves term and definition', () {
      final original = CardModel(
        id: 'card-rt',
        deckId: 'deck-rt',
        term: 'computer',
        definition: 'máy tính',
        order: 2,
        createdAt: DateTime(2024, 5, 20),
      );
      final map = original.toMap();
      final restored = CardModel.fromMap(map, original.id);
      expect(restored.term, original.term);
      expect(restored.definition, original.definition);
      expect(restored.order, original.order);
      expect(restored.deckId, original.deckId);
    });

    test('imageUrl is null by default', () {
      final card = CardModel(
        id: 'card-002',
        deckId: 'deck-001',
        term: 'school',
        definition: 'trường học',
        order: 0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(card.imageUrl, isNull);
    });

    test('copyWith updates only specified fields', () {
      final original = CardModel(
        id: 'card-003',
        deckId: 'deck-001',
        term: 'cat',
        definition: 'con mèo',
        order: 0,
        createdAt: DateTime(2024, 1, 1),
      );
      final updated = original.copyWith(definition: 'mèo');
      expect(updated.term, 'cat');
      expect(updated.definition, 'mèo');
      expect(updated.id, original.id);
    });
  });
}
