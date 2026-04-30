import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/number_formatter.dart';
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

enum _ViewMode { list, grid, table }

enum _SortColumn { code, name, price, cost, quantity, category }

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;
  _ViewMode _viewMode = _ViewMode.table;
  _SortColumn _sortColumn = _SortColumn.code;
  bool _sortAscending = true;
  int _pageSize = 8;
  int _currentPage = 1;
  final Set<int> _selectedIds = {};

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
        tooltip: 'เพิ่มสินค้าใหม่',
        child: const Icon(Icons.add),
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
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _viewMode == _ViewMode.list ? Icons.list : Icons.view_list,
                  color: _viewMode == _ViewMode.list
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _viewMode = _ViewMode.list),
                tooltip: 'แสดงแบบ List',
              ),
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: _viewMode == _ViewMode.grid
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _viewMode = _ViewMode.grid),
                tooltip: 'แสดงแบบ Grid',
              ),
              IconButton(
                icon: Icon(
                  Icons.table_chart,
                  color: _viewMode == _ViewMode.table
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () => setState(() => _viewMode = _ViewMode.table),
                tooltip: 'แสดงแบบ Table',
              ),
              if (_viewMode == _ViewMode.table && _selectedIds.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showDeleteAllConfirmation(),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text('ลบที่เลือก (${_selectedIds.length})'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[700],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _navigateToProductForm(),
                tooltip: 'เพิ่มสินค้าใหม่',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    final state = widget.bloc.state;
    if (state is! ProductLoaded) return;
    final products = state.searchResults ?? state.products;
    final toDelete = products
        .where((p) => p.id != null && _selectedIds.contains(p.id))
        .toList();
    if (toDelete.isEmpty) return;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text(
          'คุณต้องการลบสินค้าที่เลือก ${toDelete.length} รายการหรือไม่? การดำเนินการนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        widget.bloc.add(DeleteProductsEvent(toDelete));
        setState(() => _selectedIds.clear());
      }
    });
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

          if (_viewMode == _ViewMode.grid) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductGridCard(products[index]);
              },
            );
          }

          if (_viewMode == _ViewMode.table) {
            final sorted = _getSortedProducts(products);
            final totalPages =
                (sorted.length / _pageSize).ceil().clamp(1, 999999);
            final clampedPage = _currentPage.clamp(1, totalPages);
            if (_currentPage != clampedPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _currentPage = clampedPage);
              });
            }
            final pageProducts = _getPaginatedProducts(sorted);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '${NumberFormatter.formatInteger(products.length)} รายการ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: _buildProductTable(
                              pageProducts,
                              products.length,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildPaginationBar(products.length, totalPages),
              ],
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

  List<ProductModel> _getSortedProducts(List<ProductModel> products) {
    final list = List<ProductModel>.from(products);
    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case _SortColumn.code:
          cmp = a.productCode.compareTo(b.productCode);
          break;
        case _SortColumn.name:
          cmp = a.name.compareTo(b.name);
          break;
        case _SortColumn.price:
          cmp = a.price.compareTo(b.price);
          break;
        case _SortColumn.cost:
          cmp = a.cost.compareTo(b.cost);
          break;
        case _SortColumn.quantity:
          cmp = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case _SortColumn.category:
          cmp = a.category.compareTo(b.category);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  List<ProductModel> _getPaginatedProducts(List<ProductModel> products) {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, products.length);
    if (start >= products.length) return [];
    return products.sublist(start, end);
  }

  Widget _buildSortableHeader(String label, _SortColumn col) {
    final isActive = _sortColumn == col;
    return InkWell(
      onTap: () => setState(() {
        if (_sortColumn == col) {
          _sortAscending = !_sortAscending;
        } else {
          _sortColumn = col;
          _sortAscending = true;
        }
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (isActive)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          Icon(Icons.filter_list, size: 14, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildProductTable(
    List<ProductModel> products,
    int totalCount,
  ) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
        const DataColumn(
          label: SizedBox(width: 40),
          columnWidth: FixedColumnWidth(48),
        ),
        // DataColumn(
        //   label: Checkbox(
        //     value: products.isEmpty
        //         ? null
        //         : (products.every(
        //                 (p) => p.id != null && _selectedIds.contains(p.id!))
        //             ? true
        //             : (products.any(
        //                     (p) => p.id != null && _selectedIds.contains(p.id!))
        //                 ? null
        //                 : false)),
        //     tristate: true,
        //     onChanged: (v) {
        //       setState(() {
        //         if (v == true) {
        //           for (final p in products) {
        //             if (p.id != null) _selectedIds.add(p.id!);
        //           }
        //         } else {
        //           for (final p in products) {
        //             if (p.id != null) _selectedIds.remove(p.id!);
        //           }
        //         }
        //       });
        //     },
        //   ),
        // ),
        DataColumn(
          label: _buildSortableHeader('รหัส', _SortColumn.code),
          columnWidth: const FlexColumnWidth(1),
        ),
        DataColumn(
          label: _buildSortableHeader('ชื่อสินค้า', _SortColumn.name),
          columnWidth: const FlexColumnWidth(1.5),
        ),
        DataColumn(
          label: _buildSortableHeader('ราคา', _SortColumn.price),
          columnWidth: const FlexColumnWidth(0.8),
          numeric: true,
        ),
        DataColumn(
          label: _buildSortableHeader('ต้นทุน', _SortColumn.cost),
          columnWidth: const FlexColumnWidth(0.8),
          numeric: true,
        ),
        DataColumn(
          label: _buildSortableHeader('จำนวน', _SortColumn.quantity),
          columnWidth: const FlexColumnWidth(0.8),
          numeric: true,
        ),
        DataColumn(
          label: _buildSortableHeader('หมวดหมู่', _SortColumn.category),
          columnWidth: const FlexColumnWidth(1),
        ),
        const DataColumn(
          label: Text('สถานะ'),
          columnWidth: FixedColumnWidth(80),
        ),
      ],
      rows: products.map((product) {
        final isSelected =
            product.id != null && _selectedIds.contains(product.id);
        return DataRow(
          color: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.4);
            return null;
          }),
          selected: isSelected,
          onSelectChanged: (v) {
            if (product.id == null) return;
            setState(() {
              if (v == true) {
                _selectedIds.add(product.id!);
              } else {
                _selectedIds.remove(product.id!);
              }
            });
          },
          cells: [
            DataCell(
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz),
                onSelected: (value) => _handleMenuAction(value, product),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'view', child: Text('ดูรายละเอียด')),
                  const PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                  PopupMenuItem(
                    value: product.isActive ? 'deactivate' : 'activate',
                    child: Text(product.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('ลบ', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            // DataCell(
            //   Checkbox(
            //     value: isSelected,
            //     onChanged: (v) {
            //       if (product.id == null) return;
            //       setState(() {
            //         if (v == true) {
            //           _selectedIds.add(product.id!);
            //         } else {
            //           _selectedIds.remove(product.id!);
            //         }
            //       });
            //     },
            //   ),
            // ),
            DataCell(Text(product.productCode)),
            DataCell(Text(product.name)),
            DataCell(Text(NumberFormatter.formatCurrency(product.price))),
            DataCell(Text(NumberFormatter.formatCurrency(product.cost))),
            DataCell(
              Text(
                '${product.stockQuantity >= 0 ? '' : '-'}${NumberFormatter.formatStock(product.stockQuantity.abs())}',
                style: product.stockQuantity < 0
                    ? TextStyle(
                        color: Colors.red[700], fontWeight: FontWeight.w500)
                    : null,
              ),
            ),
            DataCell(
                Text(product.category.isEmpty ? 'ไม่ระบุ' : product.category)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product.hideInEcommerce
                        ? Icons.inventory_2
                        : Icons.inventory,
                    size: 20,
                    color: product.hideInEcommerce
                        ? Colors.red[400]
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    product.isActive ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: product.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPaginationBar(int totalCount, int totalPages) {
    final pageOptions = [8, 16, 24, 32];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Row(
            children: [
              const Text('แสดง'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _pageSize,
                items: pageOptions
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _pageSize = v;
                      _currentPage = 1;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _currentPage <= 1
                    ? null
                    : () => setState(() => _currentPage--),
                child: const Text('ก่อนหน้า'),
              ),
              ..._buildPageNumbers(totalPages),
              TextButton(
                onPressed: _currentPage >= totalPages
                    ? null
                    : () => setState(() => _currentPage++),
                child: const Text('ถัดไป'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    final pages = <Widget>[];
    final showPages = <int>[];
    if (totalPages <= 7) {
      showPages.addAll(List.generate(totalPages, (i) => i + 1));
    } else {
      showPages.add(1);
      if (_currentPage > 3) showPages.add(-1); // ellipsis
      for (var i = (_currentPage - 1).clamp(2, totalPages - 1);
          i <= (_currentPage + 1).clamp(2, totalPages - 1);
          i++) {
        if (!showPages.contains(i)) showPages.add(i);
      }
      if (_currentPage < totalPages - 2) showPages.add(-2); // ellipsis
      if (totalPages > 1) showPages.add(totalPages);
    }
    for (final p in showPages) {
      if (p < 0) {
        pages.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey[600])),
        ));
      } else {
        final isCurrent = p == _currentPage;
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _currentPage = p),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Text(
                      '$p',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : null,
                        fontWeight: isCurrent ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return pages;
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
            if (_getDisplayBarcode(product).isNotEmpty)
              Text('Barcode: ${_getDisplayBarcode(product)}'),
            Text('ราคา: ${NumberFormatter.formatCurrency(product.price)}'),
            Text(
                'คงเหลือ: ${NumberFormatter.formatStock(product.stockQuantity)} ${product.isLowStock ? '(ใกล้หมด!)' : ''}'),
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

  String _getDisplayBarcode(ProductModel product) {
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      return product.barcode!;
    }
    if (product.customBarcodeId != null &&
        product.customBarcodeId!.isNotEmpty) {
      return product.customBarcodeId!;
    }
    return product.productCode;
  }

  Widget _buildProductGridCard(ProductModel product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        product.isActive ? Colors.green[100] : Colors.grey[300],
                    child: Icon(
                      Icons.inventory_2,
                      color: product.isActive
                          ? Colors.green[700]
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    padding: EdgeInsets.zero,
                    onSelected: (value) => _handleMenuAction(value, product),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility, size: 20),
                          title: Text('ดูรายละเอียด',
                              style: TextStyle(fontSize: 14)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text('แก้ไข', style: TextStyle(fontSize: 14)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: product.isActive ? 'deactivate' : 'activate',
                        child: ListTile(
                          leading: Icon(
                            product.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          title: Text(
                            product.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน',
                            style: const TextStyle(fontSize: 14),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete, color: Colors.red, size: 20),
                          title: Text('ลบ',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration:
                      product.isActive ? null : TextDecoration.lineThrough,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'รหัส: ${product.productCode}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_getDisplayBarcode(product).isNotEmpty)
                Text(
                  'Barcode: ${_getDisplayBarcode(product)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.formatCurrency(product.price),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              Text(
                'คงเหลือ: ${NumberFormatter.formatStock(product.stockQuantity)} ${product.isLowStock ? '(ใกล้หมด!)' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: product.isLowStock
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
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
    if (product.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(DeleteProductEvent(product));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
