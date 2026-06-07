import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/background_wrapper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../deck/providers/deck_provider.dart';
import '../widgets/continue_card.dart';
import '../widgets/home_empty.dart';
import '../widgets/home_header.dart';
import '../widgets/recent_deck_item.dart';
import '../widgets/section_title.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../explore/presentation/widgets/home_explore_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(userDecksProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final initial =
    (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase();
    final displayName =
        user?.displayName?.split(' ').last ?? 'bạn';

    return Scaffold(
      bottomNavigationBar:
      const AppBottomNav(activeTab: BottomNavTab.home),
      body: BackgroundWrapper(
        child: SafeArea(
          child: decksAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary)),
            error: (e, _) => Center(
                child: Text('Lỗi: $e',
                    style: const TextStyle(color: Colors.white))),
            data: (decks) => Column(
              children: [
                HomeHeader(
                  initial: initial,
                  displayName: displayName,
                  email: user?.email ?? '',
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (decks.isNotEmpty) ...[
                        const SectionTitle(title: 'Đang học'),
                        ContinueCarousel(decks: decks),
                      ],
                      const HomeExploreSection(),
                      const SectionTitle(title: 'Gần đây'),
                      if (decks.isEmpty)
                        const HomeEmpty()
                      else
                        ...decks.map(
                                (deck) => RecentDeckItem(deck: deck)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}