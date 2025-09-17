import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injector.dart';
import 'features/sales/presentation/pages/pos_main_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/mode_selection_page.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/backend/presentation/pages/backend_main_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/stock/bloc/product_bloc.dart';
import 'features/stock/pages/stock_main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependencies
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'PPOS - Flutter POS System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/mode-selection': (context) => const ModeSelectionPage(),
          '/pos': (context) => const POSMainPage(),
          '/backend': (context) => const BackendMainPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/stock': (context) => BlocProvider(
                create: (context) => getIt<ProductBloc>(),
                child: const StockMainPage(),
              ),
        },
      ),
    );
  }
}
