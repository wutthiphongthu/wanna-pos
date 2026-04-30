import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../models/product_model.dart';
import '../../categories/models/category_model.dart';
import '../../../core/widgets/barcode_text_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/category_selector.dart';
import '../../../core/widgets/image_picker_widget.dart';

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

  bool _isActive = true;
  bool _isLoading = false;
  CategoryModel? _selectedCategory;
  List<String> _productImages = [];

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
    super.dispose();
  }

  void _populateForm() {
    final product = widget.product!;
    _productCodeController.text = product.productCode;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = NumberFormatter.formatCurrency(product.price);
    _costController.text = NumberFormatter.formatCurrency(product.cost);
    _stockQuantityController.text = product.stockQuantity.toString();
    _minStockLevelController.text = product.minStockLevel.toString();
    _categoryController.text = product.category;
    _barcodeController.text = product.barcode ?? '';
    _productImages = List.from(product.imageUrls);
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
            RequiredTextField(
              controller: _productCodeController,
              labelText: 'รหัสสินค้า',
              hintText: 'P001',
            ),
            const SizedBox(height: 16),
            RequiredTextField(
              controller: _nameController,
              labelText: 'ชื่อสินค้า',
              hintText: 'ชื่อสินค้า',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'รายละเอียด',
              hintText: 'รายละเอียดสินค้า',
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
                  child: CurrencyTextField(
                    controller: _priceController,
                    labelText: 'ราคาขาย',
                    hintText: '฿0.00',
                    isRequired: true,
                    showCurrencySymbol: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CurrencyTextField(
                    controller: _costController,
                    labelText: 'ต้นทุน',
                    hintText: '฿0.00',
                    isRequired: true,
                    showCurrencySymbol: true,
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
                  child: NumberTextField(
                    controller: _stockQuantityController,
                    labelText: 'จำนวนคงเหลือ',
                    hintText: '0',
                    isRequired: true,
                    minValue: 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NumberTextField(
                    controller: _minStockLevelController,
                    labelText: 'ระดับสต็อกต่ำสุด',
                    hintText: '0',
                    minValue: 0,
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

            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                  if (category != null) {
                    _categoryController.clear(); // Clear manual input
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            // Manual Category Input (Fallback)
            CustomTextField(
              controller: _categoryController,
              labelText: 'หรือพิมพ์หมวดหมู่เอง',
              hintText: 'พิมพ์ชื่อหมวดหมู่',
              prefixIcon: const Icon(Icons.edit),
              onChanged: () {
                if (_categoryController.text.isNotEmpty) {
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
            BarcodeTextField(
              controller: _barcodeController,
              labelText: 'บาร์โค้ด',
              hintText: '1234567890123',
            ),
            const SizedBox(height: 16),
            ImagePickerWidget(
              initialImages: _productImages,
              onImagesChanged: (images) {
                setState(() {
                  _productImages = images;
                });
              },
              maxImages: 3,
              labelText: 'รูปภาพสินค้า',
              enabled: !_isLoading,
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
        price:
            NumberFormatter.parseFormattedNumber(_priceController.text) ?? 0.0,
        cost: NumberFormatter.parseFormattedNumber(_costController.text) ?? 0.0,
        stockQuantity: int.parse(_stockQuantityController.text),
        minStockLevel: int.tryParse(_minStockLevelController.text) ?? 0,
        category: _selectedCategory?.name ?? _categoryController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        imageUrls: _productImages,
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
}
