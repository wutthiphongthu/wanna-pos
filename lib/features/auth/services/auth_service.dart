import 'package:injectable/injectable.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/utils/constants.dart';

@injectable
class AuthService {
  final StorageService _storageService;

  AuthService(this._storageService);

  // ตรวจสอบว่า user login อยู่หรือไม่
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ดึงข้อมูล user ที่ login อยู่
  Future<Map<String, String>?> getCurrentUser() async {
    final userId = await _storageService.getString(AppConstants.userIdKey);
    final userRole = await _storageService.getString(AppConstants.userRoleKey);
    final userEmail =
        await _storageService.getString(AppConstants.userEmailKey);
    final userFullName =
        await _storageService.getString(AppConstants.userFullNameKey);
    final token = await _storageService.getString(AppConstants.tokenKey);

    if (userId != null && token != null) {
      return {
        'userId': userId,
        'userRole': userRole ?? 'user',
        'userEmail': userEmail ?? '',
        'userFullName': userFullName ?? '',
        'token': token,
      };
    }
    return null;
  }

  // ทำการ login
  Future<Map<String, dynamic>> login(String username, String password) async {
    // จำลองการเรียก API
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (username == 'admin' && password == '1234') {
      // Mock user data
      final userData = {
        'userId': '1',
        'username': username,
        'userRole': 'admin',
        'userEmail': 'admin@dohome.com',
        'userFullName': 'ผู้ดูแลระบบ',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      // บันทึกข้อมูลลง storage
      await _storageService.setString(
          AppConstants.tokenKey, userData['token']!);
      await _storageService.setString(
          AppConstants.userIdKey, userData['userId']!);
      await _storageService.setString(
          AppConstants.userRoleKey, userData['userRole']!);
      await _storageService.setString(
          AppConstants.userEmailKey, userData['userEmail']!);
      await _storageService.setString(
          AppConstants.userFullNameKey, userData['userFullName']!);

      print(
          'AuthService.login: Saved admin token = ${userData['token']}'); // Debug

      return {
        'success': true,
        'data': userData,
      };
    } else if (username == 'cashier' && password == '1234') {
      // Mock cashier data
      final userData = {
        'userId': '2',
        'username': username,
        'userRole': 'cashier',
        'userEmail': 'cashier@dohome.com',
        'userFullName': 'พนักงานขาย',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      // บันทึกข้อมูลลง storage
      await _storageService.setString(
          AppConstants.tokenKey, userData['token']!);
      await _storageService.setString(
          AppConstants.userIdKey, userData['userId']!);
      await _storageService.setString(
          AppConstants.userRoleKey, userData['userRole']!);
      await _storageService.setString(
          AppConstants.userEmailKey, userData['userEmail']!);
      await _storageService.setString(
          AppConstants.userFullNameKey, userData['userFullName']!);

      return {
        'success': true,
        'data': userData,
      };
    } else {
      return {
        'success': false,
        'message': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      };
    }
  }

  // ทำการ logout
  Future<void> logout() async {
    await _storageService.remove(AppConstants.tokenKey);
    await _storageService.remove(AppConstants.userIdKey);
    await _storageService.remove(AppConstants.userRoleKey);
    await _storageService.remove(AppConstants.userEmailKey);
    await _storageService.remove(AppConstants.userFullNameKey);
  }
}
