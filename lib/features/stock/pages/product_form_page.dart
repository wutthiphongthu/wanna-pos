import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../models/product_model.dart';
import '../../categories/widgets/category_quick_dialog.dart';
import '../../categories/models/category_model.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockLevelController = TextEditingController();
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockQuantityController.dispose();
    _minStockLevelController.dispose();
    _categoryController.dispose();
    _barcodeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final product = widget.product!;
    _productCodeController.text = product.productCode;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _costController.text = product.cost.toString();
    _stockQuantityController.text = product.stockQuantity.toString();
    _minStockLevelController.text = product.minStockLevel.toString();
    _categoryController.text = product.category;
    _barcodeController.text = product.barcode ?? '';
    _imageUrlController.text = product.imageUrl ?? '';
    _isActive = product.isActive;

    // Note: _selectedCategory จะถูกตั้งค่าเป็น null
    // เพราะเรายังไม่มีการเชื่อมต่อกับ CategoryService
    // ในอนาคตสามารถค้นหาหมวดหมู่จาก product.category ได้
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProduct,
              child: const Text('บันทึก'),
            ),
        ],
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProductOperationFailure) {
            setState(() {
              _isLoading = false;
            });
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildPricingSection(),
                const SizedBox(height: 24),
                _buildStockSection(),
                const SizedBox(height: 24),
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildAdditionalInfoSection(),
                const SizedBox(height: 24),
                _buildStatusSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
            TextFormField(
              controller: _productCodeController,
              decoration: const InputDecoration(
                labelText: 'รหัสสินค้า *',
                hintText: 'P001',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรหัสสินค้า';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อสินค้า *',
                hintText: 'ชื่อสินค้า',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อสินค้า';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด',
                hintText: 'รายละเอียดสินค้า',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
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
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'ราคาขาย *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '฿',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกราคาขาย';
                      }
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'ต้นทุน',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '฿',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สต็อก',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวนคงเหลือ *',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกจำนวนคงเหลือ';
                      }
                      if (int.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minStockLevelController,
                    decoration: const InputDecoration(
                      labelText: 'ระดับสต็อกต่ำสุด',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'หมวดหมู่',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Category Selection Button
            InkWell(
              onTap: _showCategorySelection,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_selectedCategory != null) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            _parseCategoryColor(_selectedCategory!.color)
                                .withOpacity(0.1),
                        child: Icon(
                          _parseCategoryIcon(_selectedCategory!.iconName),
                          size: 18,
                          color: _parseCategoryColor(_selectedCategory!.color),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCategory!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (_selectedCategory!.description.isNotEmpty)
                              Text(
                                _selectedCategory!.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.category, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'เลือกหมวดหมู่สินค้า',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Manual Category Input (Fallback)
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'หรือพิมพ์หมวดหมู่เอง',
                hintText: 'พิมพ์ชื่อหมวดหมู่',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _selectedCategory =
                        null; // Clear selected category if typing manually
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
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
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'บาร์โค้ด',
                hintText: '1234567890123',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL รูปภาพ',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
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
            SwitchListTile(
              title: const Text('เปิดใช้งาน'),
              subtitle: const Text('สินค้าจะแสดงในระบบ'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.product == null ? 'เพิ่มสินค้า' : 'อัปเดตสินค้า'),
          ),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final product = ProductModel(
        id: widget.product?.id,
        productCode: _productCodeController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        cost: double.tryParse(_costController.text) ?? 0.0,
        stockQuantity: int.parse(_stockQuantityController.text),
        minStockLevel: int.tryParse(_minStockLevelController.text) ?? 0,
        category: _selectedCategory?.name ?? _categoryController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.product == null) {
        context.read<ProductBloc>().add(CreateProductEvent(product));
      } else {
        context.read<ProductBloc>().add(UpdateProductEvent(product));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCategorySelection() {
    CategoryDialogHelper.showCategorySelectionDialog(
      context,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
          _categoryController.clear(); // Clear manual input
        });
      },
    );
  }

  Color _parseCategoryColor(String? colorString) {
    if (colorString == null) return Colors.blue;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_drink':
        return Icons.local_drink;
      case 'home':
        return Icons.home;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'checkroom':
        return Icons.checkroom;
      case 'sports':
        return Icons.sports;
      case 'book':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'health_and_safety':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }
}
