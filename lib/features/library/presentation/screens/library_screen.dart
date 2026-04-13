import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/deck_model.dart';
import '../../../../shared/models/folder_model.dart';
import '../../../../shared/models/group_model.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../../../shared/widgets/background_wrapper.dart';
import '../../../../shared/widgets/create_bottom_sheet.dart';
import '../../../deck/providers/deck_provider.dart';
import '../../../folder/providers/folder_provider.dart';
import '../../../group/providers/group_provider.dart';
import '../widgets/library_deck_item.dart';
import '../widgets/library_folder_item.dart';
import '../widgets/library_group_item.dart';
import '../widgets/library_tab_bar.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<DeckModel>> decksAsync =
    ref.watch(userDecksProvider);
    final AsyncValue<List<FolderModel>> foldersAsync =
    ref.watch(userFoldersProvider);
    final AsyncValue<List<GroupModel>> groupsAsync =
    ref.watch(userGroupsProvider);

    return Scaffold(
      bottomNavigationBar:
      const AppBottomNav(activeTab: BottomNavTab.library),
      body: BackgroundWrapper(
        // ✅ overlay nhạt hơn để không mất chữ
        overlayOpacity: 0.4,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppTheme.textDark),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Thư viện',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    AppInkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => CreateBottomSheet.show(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Bar ──────────────────────────────
              LibraryTabBar(
                selectedIndex: _selectedTab,
                tabs: const ['Học phần', 'Lớp học', 'Thư mục'],
                onTabChanged: (i) =>
                    setState(() => _selectedTab = i),
              ),

              const SizedBox(height: 8),

              // ── Content ──────────────────────────────
              Expanded(
                child: _buildContent(
                    decksAsync, foldersAsync, groupsAsync),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      AsyncValue<List<DeckModel>> decksAsync,
      AsyncValue<List<FolderModel>> foldersAsync,
      AsyncValue<List<GroupModel>> groupsAsync,
      ) {
    switch (_selectedTab) {
      case 0:
        return decksAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary)),
          error: (e, _) => _buildError(e.toString()),
          data: (decks) => decks.isEmpty
              ? _buildEmpty('📚', 'Chưa có học phần nào',
              'Nhấn + để tạo học phần đầu tiên')
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            itemCount: decks.length,
            itemBuilder: (_, i) => LibraryDeckItem(
                deck: decks[i],
                colorIndex:
                i % AppTheme.deckIconColors.length),
          ),
        );
      case 1:
        return groupsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary)),
          error: (e, _) => _buildError(e.toString()),
          data: (groups) => groups.isEmpty
              ? _buildEmpty('👥', 'Chưa có lớp học nào',
              'Tạo hoặc tham gia lớp học')
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            itemCount: groups.length,
            itemBuilder: (_, i) =>
                LibraryGroupItem(group: groups[i]),
          ),
        );
      case 2:
        return foldersAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary)),
          error: (e, _) => _buildError(e.toString()),
          data: (folders) => folders.isEmpty
              ? _buildEmpty('🗂️', 'Chưa có thư mục nào',
              'Tạo thư mục để sắp xếp học phần')
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            itemCount: folders.length,
            itemBuilder: (_, i) =>
                LibraryFolderItem(folder: folders[i]),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmpty(String emoji, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textMedium, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
        child:
        Text(msg, style: const TextStyle(color: Colors.red)));
  }
}