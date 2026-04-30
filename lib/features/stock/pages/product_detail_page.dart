import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injector.dart';
import '../../../core/utils/number_formatter.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../models/product_model.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductModel? _currentProduct;
  bool _isUpdatingStock = false;
  final TextEditingController _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _stockController.text = widget.product.stockQuantity.toString();
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => getIt<ProductBloc>(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_currentProduct?.name ?? 'รายละเอียดสินค้า'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditForm(),
                tooltip: 'แก้ไข',
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _currentProduct?.isActive == true
                        ? 'deactivate'
                        : 'activate',
                    child: ListTile(
                      leading: Icon(_currentProduct?.isActive == true
                          ? Icons.visibility_off
                          : Icons.visibility),
                      title: Text(_currentProduct?.isActive == true
                          ? 'ปิดใช้งาน'
                          : 'เปิดใช้งาน'),
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
            ],
          ),
          body: BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                if (state.message.contains('ลบ')) {
                  Navigator.pop(context);
                }
              } else if (state is ProductOperationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 24),
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildPricingInfo(),
                  const SizedBox(height: 24),
                  _buildStockInfo(),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(),
                  const SizedBox(height: 24),
                  _buildStatusInfo(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildProductHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _currentProduct?.isActive == true
                  ? Colors.green[100]
                  : Colors.grey[300],
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: _currentProduct?.isActive == true
                    ? Colors.green[700]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentProduct?.name ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'รหัส: ${_currentProduct?.productCode ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentProduct?.isActive == true
                          ? Colors.green[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentProduct?.isActive == true
                          ? 'เปิดใช้งาน'
                          : 'ปิดใช้งาน',
                      style: TextStyle(
                        color: _currentProduct?.isActive == true
                            ? Colors.green[700]
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลพื้นฐาน',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ชื่อสินค้า', _currentProduct?.name ?? ''),
            _buildInfoRow('รหัสสินค้า', _currentProduct?.productCode ?? ''),
            _buildInfoRow(
                'รายละเอียด', _currentProduct?.description ?? 'ไม่มี'),
            _buildInfoRow(
                'หมวดหมู่',
                _currentProduct?.category.isNotEmpty == true
                    ? _currentProduct!.category
                    : 'ไม่ระบุ'),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    final product = _currentProduct;
    if (product == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ราคา',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'ราคาขาย',
                    NumberFormatter.formatCurrency(product.price),
                    Colors.green[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'ต้นทุน',
                    NumberFormatter.formatCurrency(product.cost),
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'กำไร',
                    '฿${product.profitMargin.toStringAsFixed(2)}',
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'อัตรากำไร',
                    '${product.profitMarginPercentage.toStringAsFixed(1)}%',
                    Colors.purple[700]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    final product = _currentProduct;
    if (product == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'สต็อก',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showStockUpdateDialog,
                  tooltip: 'แก้ไขจำนวนสต็อก',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'จำนวนคงเหลือ',
                    NumberFormatter.formatStock(product.stockQuantity),
                    product.isLowStock ? Colors.red[700]! : Colors.green[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'ระดับสต็อกต่ำสุด',
                    NumberFormatter.formatStock(product.minStockLevel),
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (product.isLowStock) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'สินค้าใกล้หมด! จำนวนคงเหลือต่ำกว่าระดับที่กำหนด',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    final product = _currentProduct;
    if (product == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลเพิ่มเติม',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('บาร์โค้ด', product.barcode ?? 'ไม่ระบุ'),
            _buildImagesInfo(product.imageUrls),
            _buildInfoRow('สร้างเมื่อ', _formatDateTime(product.createdAt)),
            _buildInfoRow('อัปเดตล่าสุด', _formatDateTime(product.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    final product = _currentProduct;
    if (product == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สถานะ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  product.isActive ? Icons.check_circle : Icons.cancel,
                  color: product.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  product.isActive ? 'เปิดใช้งาน' : 'ปิดใช้งาน',
                  style: TextStyle(
                    color: product.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesInfo(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return _buildInfoRow('รูปภาพ', 'ไม่มีรูปภาพ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'รูปภาพ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${imageUrls.length} รูป',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToEditForm() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<ProductBloc>(context),
            child: ProductFormPage(product: _currentProduct),
          ),
        )).then((_) {
      // Refresh product data when returning from edit form
      if (_currentProduct?.id != null) {
        context.read<ProductBloc>().add(LoadProductById(_currentProduct!.id!));
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'activate':
      case 'deactivate':
        if (_currentProduct?.id != null) {
          context.read<ProductBloc>().add(
                ToggleProductStatus(_currentProduct!.id!, action == 'activate'),
              );
        }
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${_currentProduct?.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentProduct != null) {
                context
                    .read<ProductBloc>()
                    .add(DeleteProductEvent(_currentProduct!));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _showStockUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขจำนวนสต็อก'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'จำนวนสต็อกใหม่',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = int.tryParse(_stockController.text);
              if (newQuantity != null && _currentProduct?.id != null) {
                context.read<ProductBloc>().add(
                      UpdateStockQuantity(_currentProduct!.id!, newQuantity),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}
