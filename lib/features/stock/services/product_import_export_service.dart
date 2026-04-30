import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/di/injector.dart';
import '../../../database/app_database.dart';
import '../../../features/auth/services/auth_service_interface.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductImportExportService {
  ProductImportExportService()
      : _productRepository = getIt<ProductRepository>(),
        _database = getIt<AppDatabase>(),
        _authService = getIt<IAuthService>();

  final ProductRepository _productRepository;
  final AppDatabase _database;
  final IAuthService _authService;

  // Template headers based on expected structure
  static const List<String> templateHeaders = [
    'Product code',
    'Product name',
    'Product subname',
    'Cost',
    'Price',
    'Discount type (1=Amount, 2=%)',
    'Discount',
    'Barcode type (1=Product code, 2=Custom code)',
    'Custom barcode id',
    'Notify when product less than',
    'Hide product in ecommerce (true or false)',
    'Non vat (true or false)',
    'Unlimited stock (true or false)',
    'Product detail',
    'Hide product in e-menu (true or false)',
    'Product Location',
  ];

  static String _normalizeHeader(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\\s+'), ' ').trim();
  }

  static String _getRowValue(Map<String, String> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      if (v != null) return v;
    }
    return '';
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final s = (value ?? '').toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
    return false;
  }

  Future<String?> exportAllProducts(BuildContext context) async {
    final result = await _productRepository.getAllProducts();
    return result.fold((failure) async {
      _showSnack(context, 'Export failed: ${failure.message}');
      return null;
    }, (products) async {
      final workbook = xls.Excel.createExcel();
      final sheet = workbook['Products'];

      // Header row
      for (int i = 0; i < templateHeaders.length; i++) {
        sheet
            .cell(xls.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = templateHeaders[i];
      }

      // Data rows
      for (int r = 0; r < products.length; r++) {
        final p = products[r];
        final values = [
          p.productCode,
          p.name,
          p.productSubname ?? '',
          p.cost,
          p.price,
          p.discountType,
          p.discount,
          p.barcodeType,
          p.barcodeType == 2 ? (p.customBarcodeId ?? (p.barcode ?? '')) : '',
          p.minStockLevel,
          p.hideInEcommerce,
          p.nonVat,
          p.unlimitedStock,
          p.description,
          p.hideInEMenu,
          p.productLocation ?? '',
        ];
        for (int c = 0; c < values.length; c++) {
          sheet
              .cell(xls.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: r + 1))
              .value = values[c];
        }
      }

      // Save file
      final bytes = workbook.encode();
      if (bytes == null) {
        _showSnack(context, 'Export failed: cannot encode workbook');
        return null;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/products_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

      _showSnack(context, 'บันทึกไฟล์เรียบร้อย: $filePath');
      return filePath;
    });
  }

  Future<int> importFromExcel(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      _showSnack(context, 'ยกเลิกการนำเข้า');
      return 0;
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      _showSnack(context, 'ไม่สามารถอ่านไฟล์ได้');
      return 0;
    }

    final excel = xls.Excel.decodeBytes(fileBytes);
    final sheet =
        excel.sheets.values.isNotEmpty ? excel.sheets.values.first : null;
    if (sheet == null || sheet.maxRows == 0) {
      _showSnack(context, 'ไฟล์ไม่ถูกต้องหรือไม่มีข้อมูล');
      return 0;
    }

    // Build header map
    final Map<int, String> indexToHeader = {};
    for (int c = 0; c < sheet.maxCols; c++) {
      final cell = sheet
          .cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      final key = (cell.value?.toString() ?? '').trim();
      if (key.isNotEmpty) indexToHeader[c] = _normalizeHeader(key);
    }

    // Preload categories for mapping (ตามร้านที่ล็อกอิน)
    final storeId = await _authService.getCurrentStoreId();
    final categories = await _database.categoryDao.getAllCategoriesByStore(storeId);
    final Map<String, int> categoryNameToId = {
      for (final e in categories) e.name: e.id ?? 0,
    };

    int imported = 0;
    // Iterate rows
    for (int r = 1; r < sheet.maxRows; r++) {
      final Map<String, String> row = {};
      for (int c = 0; c < sheet.maxCols; c++) {
        final header = indexToHeader[c];
        if (header == null) continue;
        final value = sheet
            .cell(xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
            .value;
        row[header] = value?.toString() ?? '';
      }

      final productCode = _getRowValue(row, [
        _normalizeHeader('Product code'),
        _normalizeHeader('productCode'),
      ]).trim();
      if (productCode.isEmpty) {
        continue; // skip invalid rows
      }

      double parseDouble(String? s) {
        if (s == null) return 0.0;
        final parsed = double.tryParse(s.replaceAll(',', ''));
        return parsed ?? 0.0;
      }

      int parseInt(String? s) {
        if (s == null) return 0;
        final parsed = int.tryParse(s.replaceAll(',', ''));
        return parsed ?? 0;
      }

      final images = (row['imageUrls'] ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Optional category mapping (some templates may include these columns)
      int? categoryId;
      final categoryIdRaw = _getRowValue(row, [
        _normalizeHeader('categoryId'),
      ]).trim();
      final categoryName = _getRowValue(row, [
        _normalizeHeader('category'),
      ]).trim();
      if (categoryIdRaw.isNotEmpty) {
        categoryId = parseInt(categoryIdRaw);
      } else if (categoryName.isNotEmpty) {
        categoryId = categoryNameToId[categoryName];
      }

      final barcodeType = parseInt(_getRowValue(row, [
        _normalizeHeader('Barcode type (1=Product code, 2=Custom code)'),
        _normalizeHeader('barcodeType'),
      ]));
      final customBarcodeIdRaw = _getRowValue(row, [
        _normalizeHeader('Custom barcode id'),
        _normalizeHeader('customBarcodeId'),
        _normalizeHeader('barcode'),
      ]).trim();

      final String? barcode = (barcodeType == 2)
          ? (customBarcodeIdRaw.isEmpty ? null : customBarcodeIdRaw)
          : productCode;

      final product = ProductModel(
        id: null,
        productCode: productCode,
        name: _getRowValue(row, [
          _normalizeHeader('Product name'),
          _normalizeHeader('name'),
        ]).trim(),
        productSubname: _getRowValue(row, [
          _normalizeHeader('Product subname'),
          _normalizeHeader('productSubname'),
        ]).trim().isEmpty
            ? null
            : _getRowValue(row, [
                _normalizeHeader('Product subname'),
                _normalizeHeader('productSubname'),
              ]).trim(),
        description: _getRowValue(row, [
          _normalizeHeader('Product detail'),
          _normalizeHeader('description'),
        ]).trim(),
        price: parseDouble(_getRowValue(row, [
          _normalizeHeader('Price'),
          _normalizeHeader('price'),
        ])),
        cost: parseDouble(_getRowValue(row, [
          _normalizeHeader('Cost'),
          _normalizeHeader('cost'),
        ])),
        discountType: parseInt(_getRowValue(row, [
          _normalizeHeader('Discount type (1=Amount, 2=%)'),
          _normalizeHeader('discountType'),
        ])),
        discount: parseDouble(_getRowValue(row, [
          _normalizeHeader('Discount'),
          _normalizeHeader('discount'),
        ])),
        stockQuantity: parseInt(_getRowValue(row, [
          _normalizeHeader('stockQuantity'),
        ])),
        minStockLevel: parseInt(_getRowValue(row, [
          _normalizeHeader('Notify when product less than'),
          _normalizeHeader('minStockLevel'),
        ])),
        category: _getRowValue(row, [
          _normalizeHeader('category'),
        ]).trim(),
        categoryId: categoryId,
        barcodeType: barcodeType == 0 ? 1 : barcodeType,
        customBarcodeId: customBarcodeIdRaw.isEmpty ? null : customBarcodeIdRaw,
        barcode: barcode,
        hideInEcommerce: _parseBool(_getRowValue(row, [
          _normalizeHeader('Hide product in ecommerce (true or false)'),
          _normalizeHeader('hideInEcommerce'),
        ])),
        nonVat: _parseBool(_getRowValue(row, [
          _normalizeHeader('Non vat (true or false)'),
          _normalizeHeader('nonVat'),
        ])),
        unlimitedStock: _parseBool(_getRowValue(row, [
          _normalizeHeader('Unlimited stock (true or false)'),
          _normalizeHeader('unlimitedStock'),
        ])),
        hideInEMenu: _parseBool(_getRowValue(row, [
          _normalizeHeader('Hide product in e-menu (true or false)'),
          _normalizeHeader('hideInEMenu'),
        ])),
        productLocation: _getRowValue(row, [
          _normalizeHeader('Product Location'),
          _normalizeHeader('productLocation'),
        ]).trim().isEmpty
            ? null
            : _getRowValue(row, [
                _normalizeHeader('Product Location'),
                _normalizeHeader('productLocation'),
              ]).trim(),
        imageUrls: images,
        isActive: _parseBool(_getRowValue(row, [
          _normalizeHeader('isActive'),
        ]).trim().isEmpty
            ? '1'
            : _getRowValue(row, [
                _normalizeHeader('isActive'),
              ])),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Try update first (by productCode), else insert
      final existingEither =
          await _productRepository.getProductByCode(productCode);
      final updated =
          await existingEither.fold((_) async => false, (existing) async {
        if (existing == null) return false;
        final res = await _productRepository
            .updateProduct(product.copyWith(id: existing.id));
        return res.fold((_) => false, (count) => (count) > 0);
      });
      if (!updated) {
        final res = await _productRepository.insertProduct(product);
        res.fold((_) => null, (_) => imported++);
      } else {
        imported++;
      }
    }

    _showSnack(context, 'นำเข้าสำเร็จ $imported รายการ');
    return imported;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
