import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_models.dart';

/// Service xác thực cho Admin - kiểm tra role admin
class AdminAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  /// User hiện tại
  User? get currentUser => _auth.currentUser;

  /// Stream auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng nhập admin: chỉ cho phép user có role='admin'
  /// Trả về UserCredential nếu thành công, throw nếu không phải admin
  Future<UserCredential> adminSignIn({
    required String email,
    required String password,
  }) async {
    // 1. Đăng nhập Firebase Auth
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Đăng nhập thất bại.');
    }

    // 2. Kiểm tra role trong Firestore
    final isAdmin = await _checkAdminRole(user.uid);
    if (!isAdmin) {
      // Không phải admin → đăng xuất và throw
      await _auth.signOut();
      throw AdminAccessDeniedException();
    }

    return credential;
  }

  /// Kiểm tra user hiện tại có role admin không
  Future<bool> checkCurrentUserIsAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    return _checkAdminRole(uid);
  }

  /// Đọc role từ Firestore
  Future<bool> _checkAdminRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      return data['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Lấy thông tin admin hiện tại
  Future<AdminUser?> getCurrentAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AdminUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() => _auth.signOut();

  /// Lấy danh sách tất cả user cho admin quản lý
  Future<List<AdminUser>> getAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cập nhật role của user
  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  /// Cập nhật status của user
  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _db.collection('users').doc(uid).update({'status': newStatus});
  }
}

/// Exception khi user không có quyền admin
class AdminAccessDeniedException implements Exception {
  @override
  String toString() => 'Tài khoản không có quyền truy cập Admin.';
}
