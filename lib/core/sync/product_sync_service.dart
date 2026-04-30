import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../firebase/firestore_paths.dart';
import '../../database/database_service.dart';
import '../../database/entities/product_entity.dart';
import '../../features/auth/services/auth_service_interface.dart';
import 'sync_constants.dart';

/// ดึง/ส่งสินค้าระหว่าง SQLite กับ Firestore (offline-first)
@injectable
class ProductSyncService {
  ProductSyncService(
    this._databaseService,
    this._authService,
  );

  final DatabaseService _databaseService;
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _storeIdStr() async =>
      (await _authService.getCurrentStoreId()).toString();

  ProductEntity _entityFromRemote(
    String docId,
    Map<String, dynamic> data,
    int storeId, {
    int? localId,
  }) {
    final imageUrls = data['imageUrls'];
    return ProductEntity(
      id: localId,
      storeId: storeId,
      productCode: (data['productCode'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      productSubname: data['productSubname']?.toString(),
      description: (data['description'] ?? '').toString(),
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      discountType: (data['discountType'] ?? 1) is int
          ? (data['discountType'] ?? 1) as int
          : int.tryParse((data['discountType'] ?? '1').toString()) ?? 1,
      discount: (data['discount'] ?? 0).toDouble(),
      stockQuantity: (data['stockQuantity'] ?? 0) is int
          ? (data['stockQuantity'] ?? 0) as int
          : int.tryParse((data['stockQuantity'] ?? '0').toString()) ?? 0,
      minStockLevel: (data['minStockLevel'] ?? 0) is int
          ? (data['minStockLevel'] ?? 0) as int
          : int.tryParse((data['minStockLevel'] ?? '0').toString()) ?? 0,
      category: (data['category'] ?? '').toString(),
      categoryId: data['categoryId'] != null
          ? (data['categoryId'] is int
              ? data['categoryId'] as int
              : int.tryParse(data['categoryId'].toString()))
          : null,
      barcode: data['barcode']?.toString(),
      barcodeType: (data['barcodeType'] ?? 1) is int
          ? (data['barcodeType'] ?? 1) as int
          : int.tryParse((data['barcodeType'] ?? '1').toString()) ?? 1,
      customBarcodeId: data['customBarcodeId']?.toString(),
      hideInEcommerce: data['hideInEcommerce'] == true,
      nonVat: data['nonVat'] == true,
      unlimitedStock: data['unlimitedStock'] == true,
      hideInEMenu: data['hideInEMenu'] == true,
      productLocation: data['productLocation']?.toString(),
      imageUrls: imageUrls is List
          ? jsonEncode(imageUrls.map((e) => e.toString()).toList())
          : (imageUrls != null ? jsonEncode([imageUrls.toString()]) : null),
      isActive: data['isActive'] != false,
      createdAt: (data['createdAt'] ?? 0) is int
          ? (data['createdAt'] ?? 0) as int
          : int.tryParse((data['createdAt'] ?? '0').toString()) ?? 0,
      updatedAt: (data['updatedAt'] ?? 0) is int
          ? (data['updatedAt'] ?? 0) as int
          : int.tryParse((data['updatedAt'] ?? '0').toString()) ?? 0,
      remoteId: docId,
      syncStatus: SyncStatus.clean,
    );
  }

  Map<String, dynamic> _toFirestoreMap(ProductEntity e) {
    List<String> urls = [];
    if (e.imageUrls != null && e.imageUrls!.isNotEmpty) {
      try {
        urls = List<String>.from(jsonDecode(e.imageUrls!));
      } catch (_) {}
    }
    return {
      'storeId': e.storeId.toString(),
      'productCode': e.productCode,
      'name': e.name,
      'productSubname': e.productSubname,
      'description': e.description,
      'price': e.price,
      'cost': e.cost,
      'discountType': e.discountType,
      'discount': e.discount,
      'stockQuantity': e.stockQuantity,
      'minStockLevel': e.minStockLevel,
      'category': e.category,
      'categoryId': e.categoryId,
      'barcode': e.barcode,
      'barcodeType': e.barcodeType,
      'customBarcodeId': e.customBarcodeId,
      'hideInEcommerce': e.hideInEcommerce,
      'nonVat': e.nonVat,
      'unlimitedStock': e.unlimitedStock,
      'hideInEMenu': e.hideInEMenu,
      'productLocation': e.productLocation,
      'imageUrls': urls,
      'isActive': e.isActive,
      'createdAt': e.createdAt,
      'updatedAt': e.updatedAt,
    };
  }

  /// ดึงจาก Firestore แล้ว merge ลง SQLite (last-write-wins ตาม updatedAt)
  Future<void> pullFromRemote() async {
    final storeIdStr = await _storeIdStr();
    final storeId = int.tryParse(storeIdStr) ?? 1;
    final snap = await _firestore
        .collection(FirestorePaths.storeProducts(storeIdStr))
        .get();
    final db = await _databaseService.database;

    for (final doc in snap.docs) {
      final data = doc.data();
      final remoteUpdated = (data['updatedAt'] ?? 0) is int
          ? (data['updatedAt'] ?? 0) as int
          : int.tryParse((data['updatedAt'] ?? '0').toString()) ?? 0;

      final byRemote =
          await db.productDao.getProductByRemoteId(storeId, doc.id);
      if (byRemote != null) {
        if (remoteUpdated <= byRemote.updatedAt) continue;
        final merged = _entityFromRemote(doc.id, data, storeId,
            localId: byRemote.id);
        await db.productDao.updateProduct(merged);
        continue;
      }

      final code = (data['productCode'] ?? '').toString();
      if (code.isEmpty) continue;
      final byCode = await db.productDao.getProductByCode(storeId, code);
      if (byCode != null) {
        if (remoteUpdated <= byCode.updatedAt) continue;
        final merged = _entityFromRemote(doc.id, data, storeId,
            localId: byCode.id);
        await db.productDao.updateProduct(merged);
        continue;
      }

      final insert = _entityFromRemote(doc.id, data, storeId);
      await db.productDao.insertProduct(insert);
    }
  }

  /// ลบ doc บน Firestore แล้วลบแถวใน SQLite (หลัง mark pending_delete)
  Future<void> pushPendingDeletes() async {
    final storeIdStr = await _storeIdStr();
    final storeId = int.tryParse(storeIdStr) ?? 1;
    final db = await _databaseService.database;
    final pending = await db.productDao.getPendingDeleteProductsByStore(storeId);

    for (final e in pending) {
      final docId = e.remoteId;
      if (docId != null && docId.isNotEmpty) {
        try {
          await _firestore
              .doc(FirestorePaths.storeProduct(storeIdStr, docId))
              .delete();
        } catch (_) {}
      }
      if (e.id != null) {
        await db.productDao.deleteProduct(e);
      }
    }
  }

  /// ส่งรายการที่ dirty ขึ้น Firestore แล้ว mark clean
  Future<void> pushDirtyLocal() async {
    final storeIdStr = await _storeIdStr();
    final storeId = int.tryParse(storeIdStr) ?? 1;
    final db = await _databaseService.database;
    final dirty = await db.productDao.getDirtyProductsByStore(storeId);

    for (final e in dirty) {
      final docId = e.remoteId ?? (e.id ?? DateTime.now().millisecondsSinceEpoch).toString();
      final map = _toFirestoreMap(e.copyWith(
        remoteId: docId,
        syncStatus: SyncStatus.clean,
      ));
      await _firestore
          .doc(FirestorePaths.storeProduct(storeIdStr, docId))
          .set(map);
      final clean = e.copyWith(remoteId: docId, syncStatus: SyncStatus.clean);
      if (e.id != null) {
        await db.productDao.updateProduct(clean);
      }
    }
  }
}
