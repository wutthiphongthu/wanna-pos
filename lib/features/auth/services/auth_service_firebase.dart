import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/firebase/firestore_paths.dart';
import 'auth_service_interface.dart';

/// Auth รุ่น Firebase — ใช้ Firebase Auth (อีเมล/รหัสผ่าน) + โปรไฟล์ใน Firestore /users/{uid}
/// เมื่อใช้ Firebase ให้ใส่ **อีเมล** ในช่อง username ที่หน้า login
@injectable
class AuthServiceFirebase implements IAuthService {
  final StorageService _storageService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthServiceFirebase(this._storageService);

  @override
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  @override
  Future<Map<String, String>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userId = user.uid;
    final token = await user.getIdToken();
    final storeId = await _storageService.getString(AppConstants.storeIdKey);
    final storeName = await _storageService.getString(AppConstants.storeNameKey);
    final userRole = await _storageService.getString(AppConstants.userRoleKey);
    final userFullName = await _storageService.getString(AppConstants.userFullNameKey);

    return {
      'userId': userId,
      'userRole': userRole ?? 'user',
      'userEmail': user.email ?? '',
      'userFullName': userFullName ?? user.displayName ?? '',
      'storeId': storeId ?? '1',
      'storeName': storeName ?? '',
      'token': token ?? '',
    };
  }

  @override
  Future<int> getCurrentStoreId() async {
    final storeId = await _storageService.getString(AppConstants.storeIdKey);
    return int.tryParse(storeId ?? '1') ?? 1;
  }

  @override
  Future<String> getCurrentStoreName() async {
    final name = await _storageService.getString(AppConstants.storeNameKey);
    return name ?? 'ร้านหลัก';
  }

  @override
  Future<bool> hasStore() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final userDoc = await _firestore.doc(FirestorePaths.user(user.uid)).get();
    final data = userDoc.data();
    if (data == null) return false;
    final storeId = ((data['storeId'] as String?) ?? '').trim();
    if (storeId.isEmpty) return false;
    final storeRef = _firestore.doc(FirestorePaths.store(storeId));
    final storeSnap = await storeRef.get();
    return storeSnap.exists;
  }

  @override
  Future<void> setStoreForCurrentUser(String storeId, String storeName) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final now = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.user(user.uid)).update({
      'storeId': storeId,
      'storeName': storeName,
      'updatedAt': now,
    });
    await _storageService.setString(AppConstants.storeIdKey, storeId);
    await _storageService.setString(AppConstants.storeNameKey, storeName);
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final email = username.trim();
    final pass = password;

    if (email.isEmpty || pass.isEmpty) {
      return {'success': false, 'message': 'กรุณากรอกอีเมลและรหัสผ่าน'};
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final user = credential.user;
      if (user == null) {
        return {'success': false, 'message': 'เข้าสู่ระบบไม่สำเร็จ'};
      }

      final userDoc = await _firestore.doc(FirestorePaths.user(user.uid)).get();
      if (!userDoc.exists || userDoc.data() == null) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'ไม่พบโปรไฟล์ผู้ใช้ในระบบ (ไม่มี document ใน /users/${user.uid})',
        };
      }

      final data = userDoc.data()!;
      final storeId = (data['storeId'] ?? '').toString().trim();
      final storeName = (data['storeName'] ?? 'ร้านหลัก').toString();
      final role = (data['role'] ?? 'employee').toString();
      final displayName = (data['displayName'] ?? data['userFullName'] ?? user.displayName ?? user.email ?? '').toString();

      final token = await user.getIdToken() ?? '';

      await _storageService.setString(AppConstants.userIdKey, user.uid);
      await _storageService.setString(AppConstants.userRoleKey, role);
      await _storageService.setString(AppConstants.userEmailKey, user.email ?? '');
      await _storageService.setString(AppConstants.userFullNameKey, displayName);
      await _storageService.setString(AppConstants.storeIdKey, storeId);
      await _storageService.setString(AppConstants.storeNameKey, storeName);
      await _storageService.setString(AppConstants.tokenKey, token);

      return {
        'success': true,
        'data': {
          'userId': user.uid,
          'username': user.email ?? user.uid,
          'userRole': role,
          'userEmail': user.email ?? '',
          'userFullName': displayName,
          'storeId': storeId,
          'storeName': storeName,
          'token': token,
        },
      };
    } on FirebaseAuthException catch (e) {
      String message = 'เข้าสู่ระบบไม่สำเร็จ';
      switch (e.code) {
        case 'user-not-found':
          message = 'ไม่พบผู้ใช้ที่ใช้อีเมลนี้';
          break;
        case 'wrong-password':
          message = 'รหัสผ่านไม่ถูกต้อง';
          break;
        case 'invalid-email':
          message = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        case 'invalid-credential':
          message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
          break;
        default:
          message = e.message ?? message;
      }
      return {'success': false, 'message': message};
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    final mail = email.trim();
    if (mail.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'กรุณากรอกอีเมลและรหัสผ่าน'};
    }
    if (password.length < 6) {
      return {'success': false, 'message': 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'};
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return {'success': false, 'message': 'สมัครสมาชิกไม่สำเร็จ'};
      }

      final name = displayName.trim().isNotEmpty
          ? displayName.trim()
          : (user.email?.split('@').first ?? 'ผู้ใช้');

      if (displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      final now = FieldValue.serverTimestamp();
      await _firestore.doc(FirestorePaths.user(user.uid)).set({
        'email': user.email,
        'displayName': name,
        'userFullName': name,
        'role': 'owner',
        'storeId': '',
        'storeName': '',
        'createdAt': now,
        'updatedAt': now,
      });

      final token = await user.getIdToken() ?? '';

      await _storageService.setString(AppConstants.userIdKey, user.uid);
      await _storageService.setString(AppConstants.userRoleKey, 'owner');
      await _storageService.setString(AppConstants.userEmailKey, user.email ?? '');
      await _storageService.setString(AppConstants.userFullNameKey, name);
      await _storageService.setString(AppConstants.storeIdKey, '');
      await _storageService.setString(AppConstants.storeNameKey, '');
      await _storageService.setString(AppConstants.tokenKey, token);

      return {
        'success': true,
        'data': {
          'userId': user.uid,
          'username': user.email ?? user.uid,
          'userRole': 'owner',
          'userEmail': user.email ?? '',
          'userFullName': name,
          'storeId': '',
          'storeName': '',
          'token': token,
        },
      };
    } on FirebaseAuthException catch (e) {
      String message = 'สมัครสมาชิกไม่สำเร็จ';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'อีเมลนี้ถูกใช้สมัครแล้ว';
          break;
        case 'invalid-email':
          message = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        case 'weak-password':
          message = 'รหัสผ่านอ่อนเกินไป';
          break;
        default:
          message = e.message ?? message;
      }
      return {'success': false, 'message': message};
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _storageService.remove(AppConstants.tokenKey);
    await _storageService.remove(AppConstants.userIdKey);
    await _storageService.remove(AppConstants.userRoleKey);
    await _storageService.remove(AppConstants.userEmailKey);
    await _storageService.remove(AppConstants.userFullNameKey);
    await _storageService.remove(AppConstants.storeIdKey);
    await _storageService.remove(AppConstants.storeNameKey);
  }
}
