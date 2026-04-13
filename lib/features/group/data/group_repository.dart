import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  GroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _groups => _firestore.collection('groups');

  // Lấy nhóm của user (owner hoặc member)
  Stream<List<GroupModel>> watchUserGroups(String userId) {
    return _groups
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => GroupModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    final id = _uuid.v4();
    // Tạo invite code ngắn 6 ký tự
    final inviteCode = id.substring(0, 6).toUpperCase();
    final group = GroupModel(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: [ownerId],
      deckIds: [],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );
    await _groups.doc(id).set(group.toMap());
    return group;
  }

  Stream<GroupModel?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GroupModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // Tham gia nhóm bằng invite code — trả về groupId nếu thành công, null nếu không
  Future<String?> joinGroup({
    required String inviteCode,
    required String userId,
  }) async {
    final snap = await _groups
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    final members = List<String>.from(data['memberIds'] ?? []);
    if (members.contains(userId)) return doc.id; // đã là thành viên
    await _groups.doc(doc.id).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
    return doc.id;
  }

  // Thêm deck vào nhóm
  Future<void> addDeckToGroup({
    required String groupId,
    required String deckId,
  }) async {
    await _groups.doc(groupId).update({
      'deckIds': FieldValue.arrayUnion([deckId]),
    });
  }

  // Rời nhóm
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _groups.doc(groupId).delete();
  }

  // Lắng nghe 1 nhóm theo id
 /* *Stream<GroupModel?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }*/

  Future<GroupModel?> getGroupByInviteCode(String code) async {
    final snap = await _groups
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}

final groupRepositoryProvider = Provider<GroupRepository>(
      (ref) => GroupRepository(),
);