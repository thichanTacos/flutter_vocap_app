import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/deck_model.dart';
import '../../../../shared/models/folder_model.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../../deck/providers/deck_provider.dart';
import '../../../folder/providers/folder_provider.dart';

class FolderDetailScreen extends ConsumerWidget {
  final String folderId;
  const FolderDetailScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(userFoldersProvider);
    final decksAsync = ref.watch(userDecksProvider);

    return foldersAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF1A1D28),
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF1A1D28),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (folders) {
        final folder =
            folders.where((f) => f.id == folderId).firstOrNull;
        if (folder == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1D28),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1D28),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
              child: Text('Không tìm thấy thư mục',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1A1D28),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1D28),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(folder.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF2A2D3E),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xoá thư mục',
                          style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, ref, folder);
                  }
                },
              ),
            ],
          ),
          body: decksAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary)),
            error: (e, _) => Center(
                child: Text('Lỗi: $e',
                    style: const TextStyle(color: Colors.white))),
            data: (allDecks) {
              final folderDecks = allDecks
                  .where((d) => folder.deckIds.contains(d.id))
                  .toList();

              return Column(
                children: [
                  // Info header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2D3E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.folder_outlined,
                              color: Color(0xFF00C9B1), size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${folderDecks.length} học phần',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text('Thư mục',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13)),
                          ],
                        ),
                        const Spacer(),
                        AppInkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showAddDeckSheet(
                              context, ref, folder, allDecks),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('Thêm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFF2A2D3E), height: 1),

                  // Danh sách deck
                  Expanded(
                    child: folderDecks.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined,
                              size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 16),
                          Text('Chưa có học phần nào',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn Thêm để thêm học phần vào thư mục',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: folderDecks.length,
                      itemBuilder: (context, index) {
                        final deck = folderDecks[index];
                        return _FolderDeckItem(
                          deck: deck,
                          folderId: folderId,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAddDeckSheet(
      BuildContext context,
      WidgetRef ref,
      FolderModel folder,
      List<DeckModel> allDecks,
      ) {
    final availableDecks =
    allDecks.where((d) => !folder.deckIds.contains(d.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddDeckSheet(
        availableDecks: availableDecks,
        folderId: folderId,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, FolderModel folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),
        title: const Text('Xoá thư mục',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Thư mục sẽ bị xoá nhưng các học phần bên trong vẫn còn.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(folderNotifierProvider.notifier)
                  .deleteFolder(folderId);
              context.pop();
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ── Deck Item trong folder ────────────────────────────
class _FolderDeckItem extends ConsumerWidget {
  final DeckModel deck;
  final String folderId;

  const _FolderDeckItem({
    required this.deck,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/deck/${deck.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.style_outlined,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${deck.cardCount} thẻ',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            // ✅ Dùng ref trực tiếp từ ConsumerWidget
            IconButton(
              icon: Icon(Icons.remove_circle_outline,
                  color: Colors.grey[600], size: 20),
              onPressed: () {
                ref
                    .read(folderNotifierProvider.notifier)
                    .removeDeckFromFolder(
                  folderId: folderId,
                  deckId: deck.id,
                );
              },
              tooltip: 'Xoá khỏi thư mục',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet thêm deck vào folder ────────────────────────
class _AddDeckSheet extends ConsumerWidget {
  final List<DeckModel> availableDecks;
  final String folderId;

  const _AddDeckSheet({
    required this.availableDecks,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Thêm học phần vào thư mục',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (availableDecks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tất cả học phần đã có trong thư mục',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableDecks.length,
                itemBuilder: (context, index) {
                  final deck = availableDecks[index];
                  return AppInkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      await ref
                          .read(folderNotifierProvider.notifier)
                          .addDeckToFolder(
                        folderId: folderId,
                        deckId: deck.id,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.style_outlined,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(deck.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text('${deck.cardCount} thẻ',
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12)),
                          const SizedBox(width: 8),
                          const Icon(Icons.add_circle_outline,
                              color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}