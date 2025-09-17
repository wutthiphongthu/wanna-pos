import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../models/product_model.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key, required this.bloc});
  final ProductBloc bloc;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    widget.bloc.add(const LoadActiveProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildActionBar(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มสินค้าใหม่',
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                    _showActiveOnly ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showActiveOnly = !_showActiveOnly;
                  });
                  if (_showActiveOnly) {
                    widget.bloc.add(const LoadActiveProducts());
                  } else {
                    widget.bloc.add(const LoadAllProducts());
                  }
                },
                tooltip: _showActiveOnly
                    ? 'แสดงสินค้าทั้งหมด'
                    : 'แสดงเฉพาะสินค้าที่เปิดใช้งาน',
              ),
              Text(
                _showActiveOnly ? 'สินค้าที่เปิดใช้งาน' : 'สินค้าทั้งหมด',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToProductForm(),
            tooltip: 'เพิ่มสินค้าใหม่',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.bloc.add(const ClearSearch());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            widget.bloc.add(SearchProductsEvent(value));
          } else {
            widget.bloc.add(const ClearSearch());
          }
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('สินค้าใกล้หมด'),
            selected: false,
            onSelected: (selected) {
              if (selected) {
                widget.bloc.add(const LoadLowStockProducts());
              } else {
                if (_showActiveOnly) {
                  widget.bloc.add(const LoadActiveProducts());
                } else {
                  widget.bloc.add(const LoadAllProducts());
                }
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(_showActiveOnly ? 'เฉพาะที่เปิดใช้งาน' : 'ทั้งหมด'),
            selected: true,
            onSelected: (selected) {
              setState(() {
                _showActiveOnly = !_showActiveOnly;
              });
              if (_showActiveOnly) {
                widget.bloc.add(const LoadActiveProducts());
              } else {
                widget.bloc.add(const LoadAllProducts());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
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
                    if (_showActiveOnly) {
                      widget.bloc.add(const LoadActiveProducts());
                    } else {
                      widget.bloc.add(const LoadAllProducts());
                    }
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded) {
          final products = state.searchResults ?? state.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.searchResults != null
                        ? Icons.search_off
                        : Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchResults != null
                        ? 'ไม่พบสินค้าที่ค้นหา'
                        : 'ยังไม่มีสินค้า',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (state.searchResults == null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToProductForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มสินค้าแรก'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          );
        }

        return const Center(child: Text('ไม่พบข้อมูล'));
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              product.isActive ? Colors.green[100] : Colors.grey[300],
          child: Icon(
            Icons.inventory_2,
            color: product.isActive ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: product.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รหัส: ${product.productCode}'),
            Text('ราคา: ฿${product.price.toStringAsFixed(2)}'),
            Text(
                'คงเหลือ: ${product.stockQuantity} ${product.isLowStock ? '(ใกล้หมด!)' : ''}'),
            if (product.category.isNotEmpty)
              Text('หมวดหมู่: ${product.category}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, product),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('ดูรายละเอียด'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('แก้ไข'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: product.isActive ? 'deactivate' : 'activate',
              child: ListTile(
                leading: Icon(
                    product.isActive ? Icons.visibility_off : Icons.visibility),
                title: Text(product.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('ลบ', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _navigateToProductDetail(product),
      ),
    );
  }

  void _handleMenuAction(String action, ProductModel product) {
    switch (action) {
      case 'view':
        _navigateToProductDetail(product);
        break;
      case 'edit':
        _navigateToProductForm(product: product);
        break;
      case 'activate':
      case 'deactivate':
        _toggleProductStatus(product);
        break;
      case 'delete':
        _showDeleteConfirmation(product);
        break;
    }
  }

  void _navigateToProductForm({ProductModel? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: widget.bloc,
          child: ProductFormPage(product: product),
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from form
      if (_showActiveOnly) {
        widget.bloc.add(const LoadActiveProducts());
      } else {
        widget.bloc.add(const LoadAllProducts());
      }
    });
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  void _toggleProductStatus(ProductModel product) {
    widget.bloc.add(
      ToggleProductStatus(product.id!, !product.isActive),
    );
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductBloc>().add(DeleteProductEvent(product));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
