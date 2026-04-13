import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../../../shared/widgets/background_wrapper.dart';
import '../widgets/shop_background_section.dart';
import '../widgets/shop_item_section.dart';
import '../widgets/shop_vip_section.dart';
import 'package:audioplayers/audioplayers.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Tất cả', 'Hình nền', 'Vật phẩm', 'Gói VIP'];
  int _coins = 1250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
      const AppBottomNav(activeTab: BottomNavTab.shop),
      body: BackgroundWrapper(
        overlayOpacity: 0.08,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────
              _buildHeader(),
              // ── Tab bar ─────────────────────────────
              _buildTabBar(),
              // ── Content ─────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              const Text(
                'Cửa hàng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Coin balance
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD93D),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('\$',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7a4a00))),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_coins xu',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Test âm thanh
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppInkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                try {
                  final player = AudioPlayer();
                  await player.play(AssetSource('sounds/click.mp3'));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white38),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up_outlined,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Test âm thanh',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          // Nạp xu button
          AppInkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showTopUpSheet(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white38),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Nạp xu',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.cardBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final label = entry.value;
            final isActive = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppInkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppTheme.textMedium,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    switch (_selectedTab) {
      case 0: // Tất cả
        return [
          ShopBackgroundSection(onBuy: _onBuy),
          const SizedBox(height: 20),
          ShopItemSection(onBuy: _onBuy),
          const SizedBox(height: 20),
          ShopVipSection(onBuy: _onBuyVip),
        ];
      case 1: // Hình nền
        return [ShopBackgroundSection(onBuy: _onBuy)];
      case 2: // Vật phẩm
        return [ShopItemSection(onBuy: _onBuy)];
      case 3: // Gói VIP
        return [ShopVipSection(onBuy: _onBuyVip)];
      default:
        return [];
    }
  }

  void _onBuy(String name, int price) {
    if (_coins < price) {
      _showNotEnoughCoins();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận mua',
            style: TextStyle(color: AppTheme.textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mua $name?',
                style:
                const TextStyle(color: AppTheme.textMedium)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD93D),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text('$price xu',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _coins -= price);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mua $name thành công! 🎉'),
                  backgroundColor: AppTheme.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _onBuyVip(String plan, String price) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Nâng cấp VIP',
            style: TextStyle(color: AppTheme.textDark)),
        content: Text(
          'Đăng ký gói VIP $plan với giá $price?',
          style: const TextStyle(color: AppTheme.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text('Đã đăng ký VIP $plan thành công! 👑'),
                  backgroundColor: const Color(0xFFb8860b),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  void _showNotEnoughCoins() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Không đủ xu! Hãy nạp thêm xu.'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Nạp xu',
          textColor: Colors.white,
          onPressed: _showTopUpSheet,
        ),
      ),
    );
  }

  void _showTopUpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nạp xu',
                style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...[
              _TopUpOption(
                  coins: 500, price: '10.000đ', onTap: () {
                setState(() => _coins += 500);
                Navigator.pop(context);
              }),
              _TopUpOption(
                  coins: 1200, price: '20.000đ', bonus: '+200', onTap: () {
                setState(() => _coins += 1200);
                Navigator.pop(context);
              }),
              _TopUpOption(
                  coins: 3000, price: '50.000đ', bonus: '+500', onTap: () {
                setState(() => _coins += 3000);
                Navigator.pop(context);
              }),
              _TopUpOption(
                  coins: 7000, price: '100.000đ', bonus: '+1000', onTap: () {
                setState(() => _coins += 7000);
                Navigator.pop(context);
              }),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TopUpOption extends StatelessWidget {
  final int coins;
  final String price;
  final String? bonus;
  final VoidCallback onTap;

  const _TopUpOption({
    required this.coins,
    required this.price,
    required this.onTap,
    this.bonus,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD93D),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('\$',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7a4a00))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Text(
                    '$coins xu',
                    style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  if (bonus != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(bonus!,
                          style: const TextStyle(
                              color: AppTheme.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(price,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}