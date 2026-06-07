import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/deck_model.dart';
import '../../../../../shared/widgets/app_ink_well.dart';
import '../../../deck/providers/deck_provider.dart';

class LibraryDeckItem extends ConsumerWidget {
  final DeckModel deck;
  final int? colorIndex;

  const LibraryDeckItem({super.key, required this.deck, this.colorIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = colorIndex ??
        deck.title.codeUnitAt(0) % AppTheme.deckIconColors.length;
    final color = AppTheme.deckIconColors[idx];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppInkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/deck/${deck.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.style_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.cardCount} thẻ · Học phần',
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: context.colors.textTertiary, size: 20),
                color: context.colors.card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, color: context.colors.textPrimary),
                      const SizedBox(width: 8),
                      Text('Chỉnh sửa',
                          style: TextStyle(color: context.colors.textPrimary)),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xoá', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') context.push('/deck/${deck.id}/edit');
                  if (value == 'delete') _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xoá học phần',
            style: TextStyle(
                color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xoá?',
            style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Huỷ',
                  style: TextStyle(color: context.colors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(deckNotifierProvider.notifier).deleteDeck(deck.id);
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
