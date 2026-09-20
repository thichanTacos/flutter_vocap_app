import 'package:flutter_test/flutter_test.dart';
import 'package:lizquet_app/shared/models/deck_model.dart';

void main() {
  group('Kiểm thử DeckModel', () {
    final mockId = 'deck-123';
    final mockData = {
      'title': 'Từ vựng Tiếng Anh cơ bản',
      'description': 'Các từ vựng thông dụng hàng ngày',
      'ownerId': 'user-456',
      'isPublic': true,
      'cardCount': 20,
      'createdAt': '2023-10-27T10:00:00.000Z',
      'updatedAt': '2023-10-27T12:00:00.000Z',
    };

    test('Nên chuyển đổi từ Map sang DeckModel chính xác', () {
      // Action
      final deck = DeckModel.fromMap(mockData, mockId);

      // Assert
      expect(deck.id, mockId);
      expect(deck.title, 'Từ vựng Tiếng Anh cơ bản');
      expect(deck.isPublic, true);
      expect(deck.cardCount, 20);
      expect(deck.createdAt, isA<DateTime>());
    });

    test('Nên chuyển đổi từ DeckModel sang Map chính xác để lưu lên Firebase', () {
      // Arrange
      final deck = DeckModel(
        id: mockId,
        title: 'Test Deck',
        description: 'Test Desc',
        ownerId: 'owner-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Action
      final map = deck.toMap();

      // Assert
      expect(map['title'], 'Test Deck');
      expect(map['ownerId'], 'owner-1');
      expect(map['createdAt'], isA<String>()); // Vì toMap chuyển sang ISO8601 String
    });

    test('Hàm copyWith nên tạo bản sao mới với các giá trị được thay đổi', () {
      // Arrange
      final original = DeckModel(
        id: '1',
        title: 'Gốc',
        description: 'Mô tả',
        ownerId: 'uid',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Action
      final updated = original.copyWith(title: 'Đã sửa');

      // Assert
      expect(updated.title, 'Đã sửa');
      expect(updated.description, 'Mô tả'); // Các trường khác giữ nguyên
      expect(updated.id, original.id);
    });
  });
}
