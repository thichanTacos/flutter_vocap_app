import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/deck_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../../../shared/widgets/background_wrapper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../deck/providers/deck_provider.dart';
import '../../providers/group_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() =>
      _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));

    return groupAsync.when(
      loading: () => BackgroundWrapper(
        overlayOpacity: 0.4,
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
              child:
              CircularProgressIndicator(color: AppTheme.primary)),
        ),
      ),
      error: (e, _) => BackgroundWrapper(
        overlayOpacity: 0.4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('Lỗi: $e')),
        ),
      ),
      data: (group) {
        if (group == null) {
          return BackgroundWrapper(
            overlayOpacity: 0.4,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(
                  child: Text('Không tìm thấy lớp học')),
            ),
          );
        }

        final currentUid =
            ref.watch(authStateProvider).valueOrNull?.uid ?? '';
        final isOwner = group.ownerId == currentUid;

        return BackgroundWrapper(
          overlayOpacity: 0.4,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: context.colors.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: Text('Lớp',
                  style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold)),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: context.colors.textPrimary),
                  color: context.colors.card,
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'add_deck',
                      child: Row(children: [
                        Icon(Icons.style_outlined,
                            color: AppTheme.primary),
                        SizedBox(width: 12),
                        Text('Thêm học phần'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'invite',
                      child: Row(children: [
                        Icon(Icons.person_add_outlined,
                            color: AppTheme.secondary),
                        SizedBox(width: 12),
                        Text('Thêm thành viên'),
                      ]),
                    ),
                    const PopupMenuDivider(),
                    if (isOwner)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              color: Colors.red),
                          SizedBox(width: 12),
                          Text('Xoá lớp học',
                              style: TextStyle(color: Colors.red)),
                        ]),
                      )
                    else
                      const PopupMenuItem(
                        value: 'leave',
                        child: Row(children: [
                          Icon(Icons.exit_to_app,
                              color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Rời lớp học',
                              style:
                              TextStyle(color: Colors.orange)),
                        ]),
                      ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'add_deck':
                        _showAddDeckSheet(context, group.deckIds);
                        break;
                      case 'invite':
                        _showInviteCode(group.inviteCode);
                        break;
                      case 'delete':
                        _confirmDelete();
                        break;
                      case 'leave':
                        _confirmLeave(currentUid);
                        break;
                    }
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: context.colors.textSecondary,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5),
                tabs: const [
                  Tab(text: 'HỌC PHẦN'),
                  Tab(text: 'THÀNH VIÊN'),
                ],
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header info ──────────────────────
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${group.deckIds.length} học phần',
                            style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.colors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              group.name,
                              style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        group.name,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (group.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          group.description,
                          style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── TabBarView ───────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DecksTab(
                        deckIds: group.deckIds,
                        groupId: widget.groupId,
                      ),
                      _MembersTab(
                        memberIds: group.memberIds,
                        ownerId: group.ownerId,
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

  void _showAddDeckSheet(
      BuildContext context, List<String> currentDeckIds) {
    final allDecks =
        ref.read(userDecksProvider).valueOrNull ?? [];
    final available = allDecks
        .where((d) => !currentDeckIds.contains(d.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddDeckSheet(
        availableDecks: available,
        groupId: widget.groupId,
      ),
    );
  }

  void _showInviteCode(String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mã mời lớp học',
                style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Chia sẻ mã này để mời thành viên tham gia',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.textMedium, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.dividerColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: AppTheme.textMedium),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: code));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã copy mã mời!'),
                          backgroundColor: AppTheme.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Xoá lớp học',
            style: TextStyle(color: AppTheme.textDark)),
        content: const Text('Bạn có chắc muốn xoá lớp học này?',
            style: TextStyle(color: AppTheme.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(groupNotifierProvider.notifier)
                  .deleteGroup(widget.groupId);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Rời lớp học',
            style: TextStyle(color: AppTheme.textDark)),
        content: const Text(
            'Bạn có chắc muốn rời lớp học này?',
            style: TextStyle(color: AppTheme.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(groupRepositoryProvider).leaveGroup(
                groupId: widget.groupId,
                userId: userId,
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange),
            child: const Text('Rời lớp'),
          ),
        ],
      ),
    );
  }
}

// ── Tab Học phần ──────────────────────────────────────
class _DecksTab extends ConsumerWidget {
  final List<String> deckIds;
  final String groupId;

  const _DecksTab({required this.deckIds, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(groupDecksProvider(deckIds));

    return decksAsync.when(
      loading: () => const Center(
          child:
          CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) =>
          Center(child: Text('Lỗi: $e')),
      data: (decks) {
        if (decks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.style_outlined,
                    size: 64, color: context.colors.textTertiary),
                const SizedBox(height: 12),
                Text('Chưa có học phần nào',
                    style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 15)),
                const SizedBox(height: 8),
                Text('Nhấn ··· để thêm học phần',
                    style: TextStyle(
                        color: context.colors.textTertiary,
                        fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: decks.length,
          itemBuilder: (context, i) =>
              _DeckItem(deck: decks[i], index: i),
        );
      },
    );
  }
}

// ── Deck Item ─────────────────────────────────────────
class _DeckItem extends StatelessWidget {
  final DeckModel deck;
  final int index;

  const _DeckItem({required this.deck, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme
        .deckIconColors[index % AppTheme.deckIconColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppInkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/deck/${deck.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${deck.cardCount} thuật ngữ',
                style: TextStyle(
                    color: context.colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Divider(
                  color: context.colors.divider, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(Icons.person,
                        size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text('Tác giả',
                      style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sheet thêm deck ───────────────────────────────────
class _AddDeckSheet extends ConsumerWidget {
  final List<DeckModel> availableDecks;
  final String groupId;

  const _AddDeckSheet({
    required this.availableDecks,
    required this.groupId,
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
                color: context.colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Thêm học phần vào lớp',
              style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (availableDecks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tất cả học phần đã có trong lớp',
                  style:
                  TextStyle(color: context.colors.textSecondary),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context).size.height * 0.5,
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
                          .read(groupNotifierProvider.notifier)
                          .addDeckToGroup(
                        groupId: groupId,
                        deckId: deck.id,
                      );
                      if (context.mounted)
                        Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.style_outlined,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(deck.title,
                                    style: TextStyle(
                                        color: context.colors.textPrimary,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w500)),
                                Text(
                                    '${deck.cardCount} thuật ngữ',
                                    style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_circle_outline,
                              color: AppTheme.primary, size: 22),
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

// ── Tab Thành viên ────────────────────────────────────
class _MembersTab extends ConsumerWidget {
  final List<String> memberIds;
  final String ownerId;

  const _MembersTab(
      {required this.memberIds, required this.ownerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync =
    ref.watch(groupMembersProvider(memberIds));

    return membersAsync.when(
      loading: () => const Center(
          child:
          CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) =>
          Center(child: Text('Lỗi: $e')),
      data: (members) => members.isEmpty
          ? Center(
          child: Text('Không có thành viên',
              style:
              TextStyle(color: context.colors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, i) => _MemberItem(
          user: members[i],
          isOwner: members[i].uid == ownerId,
        ),
      ),
    );
  }
}

// ── Member Item ───────────────────────────────────────
class _MemberItem extends StatelessWidget {
  final UserModel user;
  final bool isOwner;

  const _MemberItem({required this.user, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final initials = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isOwner
                  ? AppTheme.primary.withOpacity(0.15)
                  : AppTheme.secondary.withOpacity(0.15),
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(initials,
                  style: TextStyle(
                    color: isOwner
                        ? AppTheme.primary
                        : AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary
                                .withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text('Chủ lớp',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(user.email,
                      style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
