import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_data_source.dart';
import 'core/di/injector.dart';
import 'core/firebase/firebase_app.dart';
import 'core/widgets/sync_resume_listener.dart';
import 'core/utils/sample_data.dart';
import 'core/utils/theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เผื่อ Firebase — เรียกเมื่อ AppConfig.useFirebase เป็น true (ดู docs/firebase_design.md)
  await initializeFirebaseIfNeeded();

  // Configure dependencies
  await configureDependencies();

  // Seed sample data — ข้ามเมื่อใช้ Firebase (ต้อง login ก่อน และข้อมูลมาจาก Firestore)
  if (!AppConfig.useFirebase) {
    await SampleData.seedProducts();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(CheckAuthStatus()),
      child: SyncResumeListener(
        child: MaterialApp(
          title: 'PPOS - Flutter POS System',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginPage(),
          },
        ),
      ),
    );
  }
}
