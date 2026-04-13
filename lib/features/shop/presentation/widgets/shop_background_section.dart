import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_ink_well.dart';

class ShopBackgroundSection extends StatelessWidget {
  final Function(String, int) onBuy;

  const ShopBackgroundSection({super.key, required this.onBuy});

  static const List<Map<String, dynamic>> _backgrounds = [
    {
      'name': 'Galaxy',
      'colors': [Color(0xFF667eea), Color(0xFF764ba2)],
      'price': 200,
      'hot': false,
    },
    {
      'name': 'Sakura',
      'colors': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'price': 300,
      'hot': true,
    },
    {
      'name': 'Ocean',
      'colors': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'price': 350,
      'hot': false,
    },
    {
      'name': 'Forest',
      'colors': [Color(0xFF11998e), Color(0xFF38ef7d)],
      'price': 250,
      'hot': false,
    },
    {
      'name': 'Sunset',
      'colors': [Color(0xFFf7971e), Color(0xFFffd200)],
      'price': 400,
      'hot': true,
    },
    {
      'name': 'Aurora',
      'colors': [Color(0xFF00c6ff), Color(0xFF0072ff)],
      'price': 500,
      'hot': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Hình nền',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: _backgrounds.length,
          itemBuilder: (context, i) {
            final bg = _backgrounds[i];
            return AppInkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onBuy(bg['name'], bg['price']),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: bg['hot']
                      ? Border.all(
                      color: AppTheme.primary, width: 2)
                      : Border.all(
                      color: AppTheme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Preview
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: List<Color>.from(
                                      bg['colors']),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            if (bg['hot'])
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: const Text('HOT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Info
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(bg['name'],
                              style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
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
                              Text('${bg['price']}',
                                  style: TextStyle(
                                      color: bg['hot']
                                          ? AppTheme.primary
                                          : AppTheme.textMedium,
                                      fontSize: 12,
                                      fontWeight: bg['hot']
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}