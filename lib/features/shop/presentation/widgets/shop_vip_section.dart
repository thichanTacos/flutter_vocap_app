import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_ink_well.dart';

class ShopVipSection extends StatelessWidget {
  final Function(String, String) onBuy;

  const ShopVipSection({super.key, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD93D).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Gói VIP',
              style: TextStyle(
                  color: Color(0xFFb8860b),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
        const SizedBox(height: 12),

        // VIP plans
        Row(
          children: [
            _VipCard(
              plan: 'Tuần',
              price: '29.000đ',
              period: '7 ngày',
              isFeatured: false,
              onBuy: () => onBuy('Tuần', '29.000đ'),
            ),
            const SizedBox(width: 8),
            _VipCard(
              plan: 'Tháng',
              price: '79.000đ',
              period: '30 ngày',
              isFeatured: true,
              badge: 'Phổ biến',
              onBuy: () => onBuy('Tháng', '79.000đ'),
            ),
            const SizedBox(width: 8),
            _VipCard(
              plan: 'Năm',
              price: '599.000đ',
              period: '365 ngày',
              isFeatured: false,
              badge: '-40%',
              badgeColor: AppTheme.green,
              onBuy: () => onBuy('Năm', '599.000đ'),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Benefits
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VIP bao gồm:',
                  style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 12),
              ...[
                'Miễn xem quảng cáo hoàn toàn',
                'Mở khoá tất cả hình nền',
                '5 khiên bảo vệ chuỗi mỗi tháng',
                '+50 xu thưởng mỗi ngày',
                'Tạo không giới hạn bộ thẻ',
                'Truy cập tính năng AI',
              ].map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:
                        AppTheme.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: AppTheme.green, size: 13),
                    ),
                    const SizedBox(width: 10),
                    Text(benefit,
                        style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 13)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _VipCard extends StatelessWidget {
  final String plan;
  final String price;
  final String period;
  final bool isFeatured;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onBuy;

  const _VipCard({
    required this.plan,
    required this.price,
    required this.period,
    required this.isFeatured,
    required this.onBuy,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppInkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onBuy,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isFeatured
                ? AppTheme.primary.withOpacity(0.06)
                : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: isFeatured
                ? Border.all(color: AppTheme.primary, width: 2)
                : Border.all(color: AppTheme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppTheme.primary)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge!,
                      style: TextStyle(
                          color: badgeColor ?? AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                )
              else
                const SizedBox(height: 24),
              Text(plan,
                  style: const TextStyle(
                      color: AppTheme.textMedium,
                      fontSize: 12)),
              const SizedBox(height: 4),
              Text(price,
                  style: TextStyle(
                      color: isFeatured
                          ? AppTheme.primary
                          : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(period,
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 11)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: isFeatured
                      ? AppTheme.primaryGradient
                      : null,
                  color: isFeatured
                      ? null
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('Mua',
                      style: TextStyle(
                          color: isFeatured
                              ? Colors.white
                              : AppTheme.textMedium,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}