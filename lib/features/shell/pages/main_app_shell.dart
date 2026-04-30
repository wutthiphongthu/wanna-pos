import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../sales/presentation/widgets/pos_menu_drawer.dart';
import '../../sales/presentation/pages/pos_main_page.dart';
import '../../backend/presentation/pages/backend_main_page.dart';
import '../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../stock/bloc/product_bloc.dart';
import '../../stock/pages/stock_main_page.dart';
import '../../crm/presentation/pages/crm_main_page.dart';

/// Main app shell with drawer and IndexedStack.
/// Switching menu changes only the content, drawer stays accessible.
class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onSelectMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: POSMenuDrawer(
        selectedIndex: _selectedIndex,
        onSelectMenu: _onSelectMenu,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          POSMainPage(onMenuTap: _openDrawer),
          BackendMainPage(
            onMenuTap: _openDrawer,
            onNavigateToStock: () => _onSelectMenu(3),
          ),
          BlocProvider(
            create: (context) => getIt<DashboardCubit>()..load(),
            child: DashboardPage(
              onMenuTap: _openDrawer,
              onNavigateToIndex: _onSelectMenu,
            ),
          ),
          BlocProvider(
            create: (context) => getIt<ProductBloc>(),
            child: StockMainPage(onMenuTap: _openDrawer),
          ),
          CRMMainPage(onMenuTap: _openDrawer),
        ],
      ),
    );
  }
}
