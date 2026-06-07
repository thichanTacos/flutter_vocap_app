import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/card_model.dart';
import '../../../card/providers/card_provider.dart';
import '../../../deck/data/deck_repository.dart';
import '../../../../shared/widgets/app_ink_well.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(deckCardsProvider(deckId));

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: cardsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(
            child: Text('Lỗi: $e',
                style: TextStyle(color: context.colors.textPrimary))),
        data: (cards) => _buildBody(context, ref, cards),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, List<CardModel> cards) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Hero gradient header
        _HeroHeader(deckId: deckId, cardCount: cards.length, ref: ref),

        const SizedBox(height: 16),

        // Flashcard carousel preview
        _FlashcardCarousel(cards: cards),

        const SizedBox(height: 24),

        // Study mode buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn chế độ học',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _StudyModeButton(
                icon: Icons.style_rounded,
                gradient: AppTheme.primaryGradient,
                label: 'Thẻ ghi nhớ',
                subtitle: 'Lật thẻ học từ',
                onTap: () => context.push('/deck/$deckId/flashcard'),
              ),
              const SizedBox(height: 10),
              _StudyModeButton(
                icon: Icons.psychology_rounded,
                gradient: AppTheme.tealGradient,
                label: 'Học',
                subtitle: 'Trắc nghiệm & điền chỗ trống',
                onTap: () => context.push('/deck/$deckId/learn'),
              ),
              const SizedBox(height: 10),
              _StudyModeButton(
                icon: Icons.quiz_rounded,
                gradient: AppTheme.purpleGradient,
                label: 'Kiểm tra',
                subtitle: 'Bài kiểm tra tổng hợp',
                onTap: () => context.push('/deck/$deckId/test'),
              ),
              const SizedBox(height: 10),
              _StudyModeButton(
                icon: Icons.extension_rounded,
                gradient: AppTheme.yellowGradient,
                label: 'Ghép thẻ',
                subtitle: 'Trò chơi ghép cặp',
                onTap: () => context.push('/deck/$deckId/match'),
              ),
              const SizedBox(height: 10),
              _StudyModeButton(
                icon: Icons.sports_esports_rounded,
                gradient: AppTheme.greenGradient,
                label: 'Flappy Bird',
                subtitle: 'Bay qua từ vựng',
                onTap: () => context.push('/deck/$deckId/flappy'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card list header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thuật ngữ (${cards.length})',
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              AppInkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showAddCardDialog(context, ref, cards.length),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_rounded,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 4),
                      Text('Thêm thẻ',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        ...cards.map((card) => _CardListItem(
              card: card,
              deckId: deckId,
              onEdit: () => _showEditCardDialog(context, ref, card),
              onDelete: () => _confirmDeleteCard(context, ref, card),
            )),

        const SizedBox(height: 40),
      ],
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref, int order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CardFormSheet(deckId: deckId, order: order),
    );
  }

  void _showEditCardDialog(
      BuildContext context, WidgetRef ref, CardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          _CardFormSheet(deckId: deckId, card: card, order: card.order),
    );
  }

  void _confirmDeleteCard(
      BuildContext context, WidgetRef ref, CardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xoá thẻ',
            style: TextStyle(
                color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Xoá thẻ "${card.term}"?',
            style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Huỷ',
                  style: TextStyle(color: context.colors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(cardNotifierProvider.notifier)
                  .deleteCard(cardId: card.id, deckId: deckId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

}

// ── Hero Header ──────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String deckId;
  final int cardCount;
  final WidgetRef ref;

  const _HeroHeader(
      {required this.deckId, required this.cardCount, required this.ref});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(deckRepositoryProvider).getDeck(deckId),
      builder: (context, snapshot) {
        final title = snapshot.data?.title ?? '';
        final desc = snapshot.data?.description ?? '';
        return Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // AppBar row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border_rounded,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: context.colors.card,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit_outlined,
                                  color: AppTheme.textDark),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa',
                                  style:
                                      TextStyle(color: AppTheme.textDark)),
                            ]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xoá bộ thẻ',
                                  style: TextStyle(color: Colors.red)),
                            ]),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.push('/deck/$deckId/edit');
                          }
                          if (value == 'delete') {
                            // Delegate to parent
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Title & info
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(desc,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14)),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$cardCount thuật ngữ',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
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
    );
  }
}

// ── Flashcard Carousel ───────────────────────────────
class _FlashcardCarousel extends StatefulWidget {
  final List<CardModel> cards;
  const _FlashcardCarousel({required this.cards});

  @override
  State<_FlashcardCarousel> createState() => _FlashcardCarouselState();
}

class _FlashcardCarouselState extends State<_FlashcardCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('Chưa có thẻ nào',
              style:
                  TextStyle(color: context.colors.textSecondary, fontSize: 16)),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) =>
                _FlipCard(card: widget.cards[index]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.cards.length > 5 ? 5 : widget.cards.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage % 5 ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == _currentPage % 5
                    ? AppTheme.primary
                    : context.colors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Flip Card ────────────────────────────────────────
class _FlipCard extends StatefulWidget {
  final CardModel card;
  const _FlipCard({required this.card});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * 3.14159;
            final isFrontVisible = _animation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: context.colors.divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateY(isFrontVisible ? 0 : 3.14159),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            isFrontVisible
                                ? widget.card.term
                                : widget.card.definition,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Icon(Icons.touch_app_rounded,
                            color: context.colors.textTertiary, size: 18),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Text(
                          isFrontVisible
                              ? 'Nhấn để xem nghĩa'
                              : 'Nhấn để lật lại',
                          style: TextStyle(
                              color: context.colors.textTertiary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Study Mode Button ────────────────────────────────
class _StudyModeButton extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _StudyModeButton({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.colors.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Card List Item ───────────────────────────────────
class _CardListItem extends StatelessWidget {
  final CardModel card;
  final String deckId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardListItem({
    required this.card,
    required this.deckId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left color accent
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      card.term,
                      style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: context.colors.divider,
                      margin: const EdgeInsets.symmetric(horizontal: 12)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      card.definition,
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: context.colors.textTertiary, size: 20),
            color: context.colors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, color: AppTheme.textDark),
                  SizedBox(width: 8),
                  Text('Sửa', style: TextStyle(color: AppTheme.textDark)),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xoá', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
          ),
        ],
      ),
    );
  }
}

// ── Card Form Bottom Sheet ───────────────────────────
class _CardFormSheet extends ConsumerStatefulWidget {
  final String deckId;
  final CardModel? card;
  final int order;

  const _CardFormSheet(
      {required this.deckId, this.card, required this.order});

  @override
  ConsumerState<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends ConsumerState<_CardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _termController;
  late final TextEditingController _defController;
  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _termController =
        TextEditingController(text: widget.card?.term ?? '');
    _defController =
        TextEditingController(text: widget.card?.definition ?? '');
  }

  @override
  void dispose() {
    _termController.dispose();
    _defController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    bool success;
    if (_isEditing) {
      success = await ref.read(cardNotifierProvider.notifier).updateCard(
            cardId: widget.card!.id,
            term: _termController.text.trim(),
            definition: _defController.text.trim(),
          );
    } else {
      success = await ref.read(cardNotifierProvider.notifier).addCard(
            deckId: widget.deckId,
            term: _termController.text.trim(),
            definition: _defController.text.trim(),
            order: widget.order,
          );
    }
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cardNotifierProvider).isLoading;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Sửa thẻ' : 'Thêm thẻ mới',
              style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termController,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Thuật ngữ',
                prefixIcon: Icon(Icons.text_fields_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nhập thuật ngữ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _defController,
              maxLines: 2,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Định nghĩa',
                prefixIcon: Icon(Icons.notes_rounded,
                    color: AppTheme.secondary, size: 20),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nhập định nghĩa' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _save,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(_isEditing ? 'Lưu' : 'Thêm',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
