import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/card_model.dart';
import '../../../../shared/models/deck_model.dart';
import '../../../card/providers/card_provider.dart';
import '../../providers/deck_provider.dart';

class CreateEditDeckScreen extends ConsumerStatefulWidget {
  final DeckModel? deck;
  const CreateEditDeckScreen({super.key, this.deck});

  @override
  ConsumerState<CreateEditDeckScreen> createState() =>
      _CreateEditDeckScreenState();
}

class _CreateEditDeckScreenState extends ConsumerState<CreateEditDeckScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<_CardEntry> _cards = [];
  bool get _isEditing => widget.deck != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.deck!.title;
      _descController.text = widget.deck!.description;
    }
    _cards.add(_CardEntry());
    _cards.add(_CardEntry());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final c in _cards) {
      c.termController.dispose();
      c.definitionController.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tiêu đề', isError: true);
      return;
    }

    final validCards = _cards
        .where((c) =>
            c.termController.text.trim().isNotEmpty &&
            c.definitionController.text.trim().isNotEmpty)
        .toList();

    if (validCards.isEmpty) {
      _showSnack('Thêm ít nhất 1 thẻ hợp lệ', isError: true);
      return;
    }

    final success = await ref.read(deckNotifierProvider.notifier).createDeck(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
        );

    if (!success || !mounted) return;

    final decks = ref.read(userDecksProvider).valueOrNull ?? [];
    if (decks.isEmpty) return;
    final newDeck = decks.first;

    for (int i = 0; i < validCards.length; i++) {
      await ref.read(cardNotifierProvider.notifier).addCard(
            deckId: newDeck.id,
            term: validCards[i].termController.text.trim(),
            definition: validCards[i].definitionController.text.trim(),
            order: i,
          );
    }

    if (mounted) {
      _showSnack('Tạo bộ thẻ thành công! 🎉');
      context.go('/home');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? Colors.red[600] : AppTheme.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _addCard() => setState(() => _cards.add(_CardEntry()));

  void _removeCard(int index) {
    if (_cards.length <= 1) return;
    setState(() {
      _cards[index].termController.dispose();
      _cards[index].definitionController.dispose();
      _cards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(deckNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Chỉnh sửa bộ thẻ' : 'Tạo bộ thẻ mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: isLoading ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title card
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Tên bộ thẻ...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Divider(color: context.colors.divider, height: 20),
                GestureDetector(
                  onTap: _showDescDialog,
                  child: Text(
                    _descController.text.isEmpty
                        ? '+ Thêm mô tả...'
                        : _descController.text,
                    style: TextStyle(
                      color: _descController.text.isEmpty
                          ? context.colors.textTertiary
                          : context.colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Danh sách thẻ
          ..._cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            return _buildCardItem(index, card);
          }),

          const SizedBox(height: 16),

          // Add card button
          GestureDetector(
            onTap: _addCard,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_rounded,
                      color: AppTheme.primary, size: 22),
                  SizedBox(width: 8),
                  Text('Thêm thẻ mới',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCardItem(int index, _CardEntry card) {
    final color =
        AppTheme.deckIconColors[index % AppTheme.deckIconColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
                const Spacer(),
                if (_cards.length > 1)
                  GestureDetector(
                    onTap: () => _removeCard(index),
                    child: Icon(Icons.close_rounded,
                        color: AppTheme.textLight, size: 20),
                  ),
              ],
            ),
          ),
          // Term
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: card.termController,
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Thuật ngữ',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text('THUẬT NGỮ',
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600)),
          ),
          const Divider(
              color: AppTheme.dividerColor,
              height: 20,
              indent: 16,
              endIndent: 16),
          // Definition
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: TextField(
              controller: card.definitionController,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Định nghĩa',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text('ĐỊNH NGHĨA',
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDescDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mô tả',
                style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textDark),
              decoration:
                  const InputDecoration(hintText: 'Thêm mô tả cho bộ thẻ...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Xong',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardEntry {
  final TextEditingController termController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
}
