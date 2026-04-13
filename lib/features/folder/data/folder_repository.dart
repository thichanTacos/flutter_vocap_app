import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/folder_model.dart';

class FolderRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FolderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _folders => _firestore.collection('folders');

  Stream<List<FolderModel>> watchUserFolders(String userId) {
    return _folders
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FolderModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<FolderModel> createFolder({
    required String title,
    required String ownerId,
  }) async {
    final id = _uuid.v4();
    final folder = FolderModel(
      id: id,
      title: title,
      ownerId: ownerId,
      deckIds: [],
      createdAt: DateTime.now(),
    );
    await _folders.doc(id).set(folder.toMap());
    return folder;
  }

  Future<void> updateFolder({
    required String folderId,
    required String title,
  }) async {
    await _folders.doc(folderId).update({'title': title});
  }

  Future<void> addDeckToFolder({
    required String folderId,
    required String deckId,
  }) async {
    await _folders.doc(folderId).update({
      'deckIds': FieldValue.arrayUnion([deckId]),
    });
  }

  Future<void> removeDeckFromFolder({
    required String folderId,
    required String deckId,
  }) async {
    await _folders.doc(folderId).update({
      'deckIds': FieldValue.arrayRemove([deckId]),
    });
  }

  Future<void> deleteFolder(String folderId) async {
    await _folders.doc(folderId).delete();
  }
}

final folderRepositoryProvider = Provider<FolderRepository>(
      (ref) => FolderRepository(),
);