import 'package:injectable/injectable.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/utils/constants.dart';
import 'auth_service_interface.dart';

@Injectable(as: IAuthService)
class AuthService implements IAuthService {
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
    final storeId = await _storageService.getString(AppConstants.storeIdKey);
    final storeName = await _storageService.getString(AppConstants.storeNameKey);
    final token = await _storageService.getString(AppConstants.tokenKey);

    if (userId != null && token != null) {
      return {
        'userId': userId,
        'userRole': userRole ?? 'user',
        'userEmail': userEmail ?? '',
        'userFullName': userFullName ?? '',
        'storeId': storeId ?? '1',
        'storeName': storeName ?? '',
        'token': token,
      };
    }
    return null;
  }

  /// ร้านค้าที่ผู้ใช้ล็อกอินอยู่ (ใช้สำหรับ filter ข้อมูล)
  Future<int> getCurrentStoreId() async {
    final storeId = await _storageService.getString(AppConstants.storeIdKey);
    return int.tryParse(storeId ?? '1') ?? 1;
  }

  Future<String> getCurrentStoreName() async {
    return await _storageService.getString(AppConstants.storeNameKey) ?? 'ร้านหลัก';
  }

  @override
  Future<bool> hasStore() async => true;

  @override
  Future<void> setStoreForCurrentUser(String storeId, String storeName) async {}

  // ทำการ login — แยกเจ้าของร้าน (owner) กับพนักงาน (employee), ข้อมูลอ้างอิงตามร้าน
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock: admin = เจ้าของร้าน 1, cashier = พนักงานร้าน 1, owner2 = เจ้าของร้าน 2, staff2 = พนักงานร้าน 2
    final mockUsers = [
      {
        'username': 'admin',
        'password': '1234',
        'userId': '1',
        'userRole': 'owner', // เจ้าของร้าน
        'userEmail': 'admin@dohome.com',
        'userFullName': 'เจ้าของร้าน (Admin)',
        'storeId': '1',
        'storeName': 'ร้านหลัก',
      },
      {
        'username': 'cashier',
        'password': '1234',
        'userId': '2',
        'userRole': 'employee', // พนักงานขาย
        'userEmail': 'cashier@dohome.com',
        'userFullName': 'พนักงานขาย',
        'storeId': '1',
        'storeName': 'ร้านหลัก',
      },
      {
        'username': 'owner2',
        'password': '1234',
        'userId': '3',
        'userRole': 'owner',
        'userEmail': 'owner2@dohome.com',
        'userFullName': 'เจ้าของสาขา 2',
        'storeId': '2',
        'storeName': 'สาขา 2',
      },
      {
        'username': 'staff2',
        'password': '1234',
        'userId': '4',
        'userRole': 'employee',
        'userEmail': 'staff2@dohome.com',
        'userFullName': 'พนักงานสาขา 2',
        'storeId': '2',
        'storeName': 'สาขา 2',
      },
    ];

    Map<String, dynamic>? match;
    for (final u in mockUsers) {
      if ((u['username'] as String).toLowerCase() == username.trim().toLowerCase() &&
          u['password'] == password) {
        match = Map<String, dynamic>.from(u);
        break;
      }
    }

    if (match != null) {
      final userData = {
        'userId': match['userId']!,
        'username': match['username']!,
        'userRole': match['userRole']!,
        'userEmail': match['userEmail']!,
        'userFullName': match['userFullName']!,
        'storeId': match['storeId']!,
        'storeName': match['storeName']!,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      await _storageService.setString(AppConstants.tokenKey, userData['token']!);
      await _storageService.setString(AppConstants.userIdKey, userData['userId']!);
      await _storageService.setString(AppConstants.userRoleKey, userData['userRole']!);
      await _storageService.setString(AppConstants.userEmailKey, userData['userEmail']!);
      await _storageService.setString(AppConstants.userFullNameKey, userData['userFullName']!);
      await _storageService.setString(AppConstants.storeIdKey, userData['storeId']!);
      await _storageService.setString(AppConstants.storeNameKey, userData['storeName']!);

      return {'success': true, 'data': userData};
    }

    return {'success': false, 'message': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'};
  }

  // ทำการ logout
  Future<void> logout() async {
    await _storageService.remove(AppConstants.tokenKey);
    await _storageService.remove(AppConstants.userIdKey);
    await _storageService.remove(AppConstants.userRoleKey);
    await _storageService.remove(AppConstants.userEmailKey);
    await _storageService.remove(AppConstants.userFullNameKey);
    await _storageService.remove(AppConstants.storeIdKey);
    await _storageService.remove(AppConstants.storeNameKey);
  }
}
