import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../stock/bloc/product_bloc.dart';
import '../../../stock/bloc/product_event.dart';
import '../bloc/pos_bloc.dart';
import '../widgets/member_selector_dialog.dart';
import '../widgets/order_summary.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_grid.dart';

/// POS content - used inside MainAppShell IndexedStack.
class POSMainPage extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const POSMainPage({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProductBloc>()),
        BlocProvider(create: (context) => getIt<PosBloc>()),
      ],
      child: POSMainPageView(onMenuTap: onMenuTap),
    );
  }
}

class POSMainPageView extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const POSMainPageView({super.key, this.onMenuTap});

  @override
  State<POSMainPageView> createState() => _POSMainPageViewState();
}

class _POSMainPageViewState extends State<POSMainPageView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadActiveProducts());
    // แสดง popup เลือกลูกค้าก่อนเสมอ — ถ้าไม่ใส่ลูกค้าสามารถปิดแล้วขายต่อได้
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSelectCustomerOnce());
  }

  /// แสดง dialog เลือกลูกค้าครั้งเดียวเมื่อเข้าหน้าขาย (ปิดได้โดยไม่เลือกเพื่อขายแบบไม่ระบุลูกค้า)
  Future<void> _showSelectCustomerOnce() async {
    if (!mounted) return;
    final member = await MemberSelectorDialog.show(context, current: null);
    if (!mounted) return;
    context.read<PosBloc>().add(SelectMember(member));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            POSHeader(onMenuTap: widget.onMenuTap),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      child: const ProductGrid(),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: OrderSummary(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
