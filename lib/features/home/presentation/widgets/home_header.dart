import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../deck/providers/deck_provider.dart';
import '../../../../../shared/models/deck_model.dart';

class HomeHeader extends ConsumerWidget {
  final String initial;
  final String displayName;
  final String email;

  const HomeHeader({
    super.key,
    required this.initial,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          GestureDetector(
            onTap: () => _showSearch(context, ref),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: context.colors.textTertiary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Tìm kiếm bộ thẻ...',
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 17) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    final decks = ref.read(userDecksProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SearchSheet(decks: decks),
    );
  }
}

// ── Search Sheet ─────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final List<DeckModel> decks;
  const _SearchSheet({required this.decks});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  List<DeckModel> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.decks;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _results = query.isEmpty
          ? widget.decks
          : widget.decks
              .where((d) =>
                  d.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Search input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(color: context.colors.textPrimary),
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Tìm bộ thẻ...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: context.colors.textTertiary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: context.colors.textTertiary),
                          onPressed: () {
                            _controller.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Results
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 56, color: context.colors.textTertiary),
                          const SizedBox(height: 12),
                          Text('Không tìm thấy bộ thẻ nào',
                              style: TextStyle(
                                  color: context.colors.textSecondary, fontSize: 15)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _results.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final deck = _results[index];
                        final color = AppTheme.deckIconColors[
                            index % AppTheme.deckIconColors.length];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 6),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.style_rounded,
                                color: color, size: 24),
                          ),
                          title: Text(deck.title,
                              style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text('${deck.cardCount} thẻ',
                              style: TextStyle(
                                  color: context.colors.textSecondary, fontSize: 13)),
                          trailing: Icon(Icons.chevron_right,
                              color: context.colors.textTertiary),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/deck/${deck.id}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
