import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/folder_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/folder_repository.dart';

final userFoldersProvider = StreamProvider<List<FolderModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(folderRepositoryProvider).watchUserFolders(user.uid);
});

class FolderNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createFolder({required String title}) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Chưa đăng nhập');
      await ref.read(folderRepositoryProvider).createFolder(
        title: title,
        ownerId: user.uid,
      );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> addDeckToFolder({
    required String folderId,
    required String deckId,
  }) async {
    try {
      await ref.read(folderRepositoryProvider).addDeckToFolder(
        folderId: folderId,
        deckId: deckId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFolder(String folderId) async {
    state = const AsyncLoading();
    try {
      await ref.read(folderRepositoryProvider).deleteFolder(folderId);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
  Future<void> removeDeckFromFolder({
    required String folderId,
    required String deckId,
  }) async {
    try {
      await ref.read(folderRepositoryProvider).removeDeckFromFolder(
        folderId: folderId,
        deckId: deckId,
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final folderNotifierProvider =
AsyncNotifierProvider<FolderNotifier, void>(FolderNotifier.new);