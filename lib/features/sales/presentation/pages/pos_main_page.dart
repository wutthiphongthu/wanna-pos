import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../bloc/sales_bloc.dart';
import '../widgets/product_grid.dart';
import '../widgets/order_summary.dart';

import '../widgets/pos_header.dart';
import '../widgets/pos_bottom_actions.dart';

class POSMainPage extends StatelessWidget {
  const POSMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SalesBloc>(),
      child: const POSMainPageView(),
    );
  }
}

class POSMainPageView extends StatefulWidget {
  const POSMainPageView({super.key});

  @override
  State<POSMainPageView> createState() => _POSMainPageViewState();
}

class _POSMainPageViewState extends State<POSMainPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const POSHeader(),

            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Left Panel - Product Catalog
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      child: const ProductGrid(),
                    ),
                  ),

                  // Right Panel - Order Summary
                  const Expanded(
                    flex: 1,
                    child: OrderSummary(),
                  ),
                ],
              ),
            ),

            // Bottom Actions
            const POSBottomActions(),
          ],
        ),
      ),
    );
  }
}
