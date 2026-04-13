import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_ink_well.dart';

class ShopItemSection extends StatelessWidget {
  final Function(String, int) onBuy;

  const ShopItemSection({super.key, required this.onBuy});

  static const List<Map<String, dynamic>> _items = [
    {
      'name': 'Khiên bảo vệ chuỗi',
      'desc': 'Giữ chuỗi khi bỏ lỡ 1 ngày',
      'price': 100,
      'colors': [Color(0xFFf9ca24), Color(0xFFf0932b)],
      'icon': Icons.shield_outlined,
    },
    {
      'name': 'Nhân đôi điểm',
      'desc': 'Tăng gấp đôi điểm trong 1 giờ',
      'price': 150,
      'colors': [Color(0xFFa29bfe), Color(0xFF6c5ce7)],
      'icon': Icons.star_outline,
    },
    {
      'name': 'Bỏ qua quảng cáo (7 ngày)',
      'desc': 'Miễn xem quảng cáo trong 1 tuần',
      'price': 200,
      'colors': [Color(0xFF00D4AA), Color(0xFF00B4D8)],
      'icon': Icons.block_outlined,
    },
    {
      'name': 'Gợi ý thẻ AI',
      'desc': 'AI tạo thẻ từ vựng tự động x10',
      'price': 300,
      'colors': [Color(0xFFFF6B9D), Color(0xFFFF8C42)],
      'icon': Icons.auto_awesome_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Vật phẩm',
              style: TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
        const SizedBox(height: 12),
        ..._items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppInkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onBuy(item['name'], item['price']),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                        List<Color>.from(item['colors']),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(item['name'],
                            style: const TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(item['desc'],
                            style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Price button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD93D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${item['price']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}