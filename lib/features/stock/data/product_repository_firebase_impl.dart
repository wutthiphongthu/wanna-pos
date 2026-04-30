import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../auth/services/auth_service_interface.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class ProductRepositoryFirebaseImpl implements ProductRepository {
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductRepositoryFirebaseImpl(this._authService);

  Future<String> _storeId() async =>
      (await _authService.getCurrentStoreId()).toString();

  ProductModel _fromDoc(String docId, Map<String, dynamic> data) {
    final imageUrls = data['imageUrls'];
    return ProductModel(
      id: int.tryParse(docId) ?? 0,
      storeId: int.tryParse((data['storeId'] ?? '1').toString()) ?? 1,
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
          ? imageUrls.map((e) => e.toString()).toList()
          : (imageUrls != null ? [imageUrls.toString()] : []),
      isActive: data['isActive'] != false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (data['createdAt'] ?? 0) is int
              ? (data['createdAt'] ?? 0) as int
              : int.tryParse((data['createdAt'] ?? '0').toString()) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (data['updatedAt'] ?? 0) is int
              ? (data['updatedAt'] ?? 0) as int
              : int.tryParse((data['updatedAt'] ?? '0').toString()) ?? 0),
    );
  }

  Map<String, dynamic> _toMap(ProductModel p) => {
        'storeId': p.storeId.toString(),
        'productCode': p.productCode,
        'name': p.name,
        'productSubname': p.productSubname,
        'description': p.description,
        'price': p.price,
        'cost': p.cost,
        'discountType': p.discountType,
        'discount': p.discount,
        'stockQuantity': p.stockQuantity,
        'minStockLevel': p.minStockLevel,
        'category': p.category,
        'categoryId': p.categoryId,
        'barcode': p.barcode,
        'barcodeType': p.barcodeType,
        'customBarcodeId': p.customBarcodeId,
        'hideInEcommerce': p.hideInEcommerce,
        'nonVat': p.nonVat,
        'unlimitedStock': p.unlimitedStock,
        'hideInEMenu': p.hideInEMenu,
        'productLocation': p.productLocation,
        'imageUrls': p.imageUrls,
        'isActive': p.isActive,
        'createdAt': p.createdAt.millisecondsSinceEpoch,
        'updatedAt': p.updatedAt.millisecondsSinceEpoch,
      };

  @override
  Future<Either<Failure, List<ProductModel>>> getAllProducts() async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeProducts(storeId))
          .get();
      final list = snap.docs
          .map((d) => _fromDoc(d.id, d.data()))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getActiveProducts() async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeProducts(storeId))
          .where('isActive', isEqualTo: true)
          .get();
      return Right(
          snap.docs.map((d) => _fromDoc(d.id, d.data())).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductById(int id) async {
    try {
      final storeId = await _storeId();
      final doc = await _firestore
          .doc(FirestorePaths.storeProduct(storeId, id.toString()))
          .get();
      if (!doc.exists || doc.data() == null) return Right(null);
      return Right(_fromDoc(doc.id, doc.data()!));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductByCode(
      String productCode) async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeProducts(storeId))
          .where('productCode', isEqualTo: productCode)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return Right(null);
      return Right(_fromDoc(snap.docs.first.id, snap.docs.first.data()));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductByBarcode(
      String barcode) async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeProducts(storeId))
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return Right(null);
      return Right(_fromDoc(snap.docs.first.id, snap.docs.first.data()));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(
      String searchTerm) async {
    try {
      final result = await getAllProducts();
      return result.fold(
        (f) => Left(f),
        (list) {
          final term = searchTerm.toLowerCase();
          final filtered = list
              .where((p) =>
                  p.name.toLowerCase().contains(term) ||
                  p.productCode.toLowerCase().contains(term) ||
                  (p.barcode?.toLowerCase().contains(term) ?? false))
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getProductsByCategory(
      String category) async {
    try {
      final result = await getAllProducts();
      return result.fold(
        (f) => Left(f),
        (list) => Right(list.where((p) => p.category == category).toList()),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getLowStockProducts() async {
    try {
      final result = await getAllProducts();
      return result.fold(
        (f) => Left(f),
        (list) => Right(list.where((p) => p.stockQuantity <= p.minStockLevel).toList()),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    try {
      final result = await getAllProducts();
      return result.fold(
        (f) => Left(f),
        (list) {
          final cats = list.map((p) => p.category).toSet().toList()..sort();
          return Right(cats);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> insertProduct(ProductModel product) async {
    try {
      final storeId = await _storeId();
      final id = product.id ?? DateTime.now().millisecondsSinceEpoch;
      final docId = id.toString();
      final now = DateTime.now();
      final data = _toMap(product.copyWith(
        id: id,
        storeId: int.tryParse(storeId) ?? 1,
        createdAt: now,
        updatedAt: now,
      ));
      data['createdAt'] = now.millisecondsSinceEpoch;
      data['updatedAt'] = now.millisecondsSinceEpoch;
      await _firestore
          .doc(FirestorePaths.storeProduct(storeId, docId))
          .set(data);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateProduct(ProductModel product) async {
    try {
      final storeId = await _storeId();
      final docId = (product.id ?? 0).toString();
      final now = DateTime.now();
      final data = _toMap(product.copyWith(updatedAt: now));
      data['updatedAt'] = now.millisecondsSinceEpoch;
      await _firestore
          .doc(FirestorePaths.storeProduct(storeId, docId))
          .update(data);
      return Right(product.id ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> deleteProduct(ProductModel product) async {
    try {
      final storeId = await _storeId();
      final docId = (product.id ?? 0).toString();
      await _firestore
          .doc(FirestorePaths.storeProduct(storeId, docId))
          .delete();
      return Right(product.id ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateStockQuantity(
      int id, int newQuantity) async {
    try {
      final result = await getProductById(id);
      return result.fold(
        (f) => Left(f),
        (p) async {
          if (p == null) return Left(DatabaseFailure('Product not found'));
          return updateProduct(p.copyWith(stockQuantity: newQuantity));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateProductStatus(
      int id, bool isActive) async {
    try {
      final result = await getProductById(id);
      return result.fold(
        (f) => Left(f),
        (p) async {
          if (p == null) return Left(DatabaseFailure('Product not found'));
          return updateProduct(p.copyWith(isActive: isActive));
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveProductCount() async {
    final result = await getActiveProducts();
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.length),
    );
  }

  @override
  Future<Either<Failure, int>> getLowStockProductCount() async {
    final result = await getLowStockProducts();
    return result.fold(
      (f) => Left(f),
      (list) => Right(list.length),
    );
  }
}
