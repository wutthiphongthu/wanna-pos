import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/app_data_source.dart';
import '../../features/auth/services/auth_service_firebase.dart';
import '../../features/auth/services/auth_service_interface.dart';
import '../../features/categories/services/category_service_firebase.dart';
import '../../features/categories/services/category_service_interface.dart';
import '../../features/loyalty/services/loyalty_points_config_service_firebase.dart';
import '../../features/loyalty/services/loyalty_points_config_service_interface.dart';
import '../../features/members/data/member_repository_firebase_impl.dart';
import '../../features/members/repositories/member_repository.dart';
import '../../features/sales/data/sales_repository_firebase_impl.dart';
import '../../features/sales/data/sales_repository_interface.dart';
import '../../features/stock/data/product_repository_firebase_impl.dart';
import '../../features/stock/repositories/product_repository.dart';
import 'injector.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  // Firebase Auth เสมอ — ข้อมูลธุรกิจใช้ SQLite (offline-first) + SyncManager ซิงก์ Firestore
  final authImpl = getIt<AuthServiceFirebase>();
  getIt.unregister<IAuthService>();
  getIt.registerSingleton<IAuthService>(authImpl);

  // ไม่สลับ ProductRepository / ISalesRepository ฯลฯ ไป Firebase — UI ใช้ SQLite เสมอ
  // Firebase impl ลงทะเบียนโดย injectable สำหรับ SyncManager เท่านั้น
  if (AppConfig.useFirebase) {
    // Legacy: โหมดทดสอบ Firestore ตรง (ไม่ offline-first)
    getIt.unregister<ISalesRepository>();
    getIt.registerSingleton<ISalesRepository>(getIt<SalesRepositoryFirebaseImpl>());

    getIt.unregister<ProductRepository>();
    getIt.registerSingleton<ProductRepository>(getIt<ProductRepositoryFirebaseImpl>());

    getIt.unregister<MemberRepository>();
    getIt.registerSingleton<MemberRepository>(getIt<MemberRepositoryFirebaseImpl>());

    getIt.unregister<ICategoryService>();
    getIt.registerSingleton<ICategoryService>(getIt<CategoryServiceFirebase>());

    getIt.unregister<ILoyaltyPointsConfigService>();
    getIt.registerSingleton<ILoyaltyPointsConfigService>(
      getIt<LoyaltyPointsConfigServiceFirebase>(),
    );
  }
}
