import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/deck_model.dart';
import '../../../shared/models/group_model.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/group_repository.dart';

final userGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchUserGroups(user.uid);
});

final groupByIdProvider =
StreamProvider.family<GroupModel?, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
});

// ✅ Lấy decks trực tiếp từ Firestore theo ids
final groupDecksProvider =
FutureProvider.family<List<DeckModel>, List<String>>(
        (ref, deckIds) async {
      if (deckIds.isEmpty) return [];
      final firestore = FirebaseFirestore.instance;
      final results = await Future.wait(
        deckIds.map((id) => firestore.collection('decks').doc(id).get()),
      );
      return results
          .where((doc) => doc.exists)
          .map((doc) =>
          DeckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });

// ✅ Lấy members trực tiếp từ Firestore theo ids
final groupMembersProvider =
FutureProvider.family<List<UserModel>, List<String>>(
        (ref, memberIds) async {
      if (memberIds.isEmpty) return [];
      final firestore = FirebaseFirestore.instance;
      final results = await Future.wait(
        memberIds.map((id) => firestore.collection('users').doc(id).get()),
      );
      return results
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromMap(doc.data()!))
          .toList();
    });

class GroupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<GroupModel?> createGroup({
    required String name,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Chưa đăng nhập');
      final group =
      await ref.read(groupRepositoryProvider).createGroup(
        name: name,
        description: description,
        ownerId: user.uid,
      );
      state = const AsyncData(null);
      return group;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<String?> joinGroup(String inviteCode) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Chưa đăng nhập');
      final groupId =
      await ref.read(groupRepositoryProvider).joinGroup(
        inviteCode: inviteCode,
        userId: user.uid,
      );
      state = const AsyncData(null);
      return groupId;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> addDeckToGroup({
    required String groupId,
    required String deckId,
  }) async {
    try {
      await ref.read(groupRepositoryProvider).addDeckToGroup(
        groupId: groupId,
        deckId: deckId,
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).deleteGroup(groupId);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final groupNotifierProvider =
AsyncNotifierProvider<GroupNotifier, void>(GroupNotifier.new);

final groupRepositoryProvider = Provider<GroupRepository>(
      (ref) => GroupRepository(),
);