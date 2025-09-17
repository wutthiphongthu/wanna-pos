import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'product_list_page.dart';
import '../../auth/widgets/logout_menu.dart';
import '../../categories/widgets/category_quick_dialog.dart';

class StockMainPage extends StatefulWidget {
  const StockMainPage({super.key});

  @override
  State<StockMainPage> createState() => _StockMainPageState();
}

class _StockMainPageState extends State<StockMainPage> {
  int _selectedIndex = 0;
  late ProductBloc _bloc;
  late List<Widget> _pages;

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2),
      label: 'สินค้าทั้งหมด',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'ภาพรวม',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.warning),
      label: 'ใกล้หมด',
    ),
  ];
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ProductBloc>(context);
    _pages = [
      ProductListPage(bloc: _bloc),
      StockOverviewPage(bloc: _bloc),
      LowStockPage(bloc: _bloc),
    ];
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'สินค้าทั้งหมด';
      case 1:
        return 'ภาพรวมสต็อก';
      case 2:
        return 'สินค้าใกล้หมด';
      default:
        return 'จัดการสต็อก';
    }
  }

  void _refreshCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        // ProductListPage - refresh according to current filter
        _bloc.add(const LoadActiveProducts());
        break;
      case 1:
        // StockOverviewPage - refresh all products
        _bloc.add(const LoadAllProducts());
        break;
      case 2:
        // LowStockPage - refresh low stock products
        _bloc.add(const LoadLowStockProducts());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshCurrentPage(),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () =>
                CategoryDialogHelper.showCategoryManagementDialog(context),
            tooltip: 'จัดการหมวดหมู่ด่วน',
          ),
          const LogoutMenu(),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class StockOverviewPage extends StatelessWidget {
  const StockOverviewPage({super.key, required this.bloc});
  final ProductBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(const LoadAllProducts());
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded) {
          return _buildOverviewContent(context, state.products);
        }

        return const Center(child: Text('ไม่พบข้อมูล'));
      },
    );
  }

  Widget _buildOverviewContent(BuildContext context, List<dynamic> products) {
    final activeProducts = products.where((p) => p.isActive).length;
    final lowStockProducts =
        products.where((p) => p.isLowStock && p.isActive).length;
    final totalValue =
        products.fold<double>(0, (sum, p) => sum + (p.price * p.stockQuantity));
    final categories = products.map((p) => p.category).toSet().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(context, activeProducts, lowStockProducts, totalValue,
              categories),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(context, products),
          const SizedBox(height: 24),
          _buildTopProducts(context, products),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, int activeProducts,
      int lowStockProducts, double totalValue, int categories) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          context,
          'สินค้าทั้งหมด',
          activeProducts.toString(),
          Icons.inventory_2,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'ใกล้หมด',
          lowStockProducts.toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'มูลค่ารวม',
          '฿${totalValue.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'หมวดหมู่',
          categories.toString(),
          Icons.category,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, List<dynamic> products) {
    final categoryMap = <String, int>{};
    for (var product in products) {
      if (product.isActive && product.category.isNotEmpty) {
        categoryMap[product.category] =
            (categoryMap[product.category] ?? 0) + 1;
      }
    }

    if (categoryMap.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'หมวดหมู่สินค้า',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('ไม่มีข้อมูลหมวดหมู่'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'หมวดหมู่สินค้า',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...categoryMap.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(BuildContext context, List<dynamic> products) {
    final topProducts = products.where((p) => p.isActive).toList()
      ..sort((a, b) =>
          (b.price * b.stockQuantity).compareTo(a.price * a.stockQuantity));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สินค้ามูลค่าสูงสุด',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (topProducts.isEmpty)
              const Text('ไม่มีข้อมูลสินค้า')
            else
              ...topProducts.take(5).map((product) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '฿${(product.price * product.stockQuantity).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class LowStockPage extends StatelessWidget {
  const LowStockPage({super.key, required this.bloc});
  final ProductBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(const LoadLowStockProducts());
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded) {
          final lowStockProducts = state.products;

          if (lowStockProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มีสินค้าใกล้หมด',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: Icon(Icons.warning, color: Colors.red[700]),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รหัส: ${product.productCode}'),
                      Text(
                          'คงเหลือ: ${product.stockQuantity} / ${product.minStockLevel}'),
                      Text('ราคา: ฿${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to product detail or edit
                    },
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('ไม่พบข้อมูล'));
      },
    );
  }
}
