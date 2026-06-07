import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // userChanges() tự emit khi displayName thay đổi (authStateChanges không làm vậy)
  Stream<User?> get authStateChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _saveUserToFirestore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(newName.trim());
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'displayName': newName.trim()});
  }

  // Chuyển lỗi Firebase sang tiếng Việt
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng';
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu, tối thiểu 6 ký tự';
      case 'too-many-requests':
        return 'Đăng nhập quá nhiều lần, thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng, kiểm tra internet';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hoá';
      default:
        return 'Đã có lỗi xảy ra, thử lại sau';
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  // Lấy nhiều user theo danh sách uid
  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures =
    ids.map((id) => _firestore.collection('users').doc(id).get());
    final docs = await Future.wait(futures);
    return docs
        .where((doc) => doc.exists && doc.data() != null)
        .map((doc) => UserModel.fromMap(doc.data()!))
        .toList();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepository(),
);