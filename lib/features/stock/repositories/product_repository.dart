import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/sync/sync_constants.dart';
import '../../../database/database_service.dart';
import '../../../database/entities/product_entity.dart';
import '../../../features/auth/services/auth_service_interface.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductModel>>> getAllProducts();
  Future<Either<Failure, List<ProductModel>>> getActiveProducts();
  Future<Either<Failure, ProductModel?>> getProductById(int id);
  Future<Either<Failure, ProductModel?>> getProductByCode(String productCode);
  Future<Either<Failure, ProductModel?>> getProductByBarcode(String barcode);
  Future<Either<Failure, List<ProductModel>>> searchProducts(String searchTerm);
  Future<Either<Failure, List<ProductModel>>> getProductsByCategory(
      String category);
  Future<Either<Failure, List<ProductModel>>> getLowStockProducts();
  Future<Either<Failure, List<String>>> getAllCategories();
  Future<Either<Failure, int>> insertProduct(ProductModel product);
  Future<Either<Failure, int>> updateProduct(ProductModel product);
  Future<Either<Failure, int>> deleteProduct(ProductModel product);
  Future<Either<Failure, int>> updateStockQuantity(int id, int newQuantity);
  Future<Either<Failure, int>> updateProductStatus(int id, bool isActive);
  Future<Either<Failure, int>> getActiveProductCount();
  Future<Either<Failure, int>> getLowStockProductCount();
}

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final DatabaseService _databaseService;
  final IAuthService _authService;

  ProductRepositoryImpl(this._databaseService, this._authService);

  Future<int> _storeId() => _authService.getCurrentStoreId();

  @override
  Future<Either<Failure, List<ProductModel>>> getAllProducts() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entities = await database.productDao.getAllProductsByStore(storeId);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getActiveProducts() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entities = await database.productDao.getActiveProductsByStore(storeId);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductById(int id) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductById(storeId, id);
      if (entity == null) return Right(null);
      return Right(ProductModel.fromEntity(entity));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductByCode(
      String productCode) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductByCode(storeId, productCode);
      if (entity == null) return Right(null);
      return Right(ProductModel.fromEntity(entity));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductByBarcode(
      String barcode) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductByBarcode(storeId, barcode);
      if (entity == null) return Right(null);
      return Right(ProductModel.fromEntity(entity));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(
      String searchTerm) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final term = '%$searchTerm%';
      final entities = await database.productDao.searchProductsByStore(storeId, term);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getProductsByCategory(
      String category) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entities =
          await database.productDao.getProductsByCategory(storeId, category);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getLowStockProducts() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final entities = await database.productDao.getLowStockProductsByStore(storeId);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final categories = await database.productDao.getAllCategoriesByStore(storeId);
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> insertProduct(ProductModel product) async {
    try {
      final storeId = await _storeId();
      final entity = ProductEntity.fromDateTime(
        id: product.id,
        storeId: storeId,
        productCode: product.productCode,
        name: product.name,
        productSubname: product.productSubname,
        description: product.description,
        price: product.price,
        cost: product.cost,
        discountType: product.discountType,
        discount: product.discount,
        stockQuantity: product.stockQuantity,
        minStockLevel: product.minStockLevel,
        category: product.category,
        categoryId: product.categoryId,
        barcode: product.barcode,
        barcodeType: product.barcodeType,
        customBarcodeId: product.customBarcodeId,
        hideInEcommerce: product.hideInEcommerce,
        nonVat: product.nonVat,
        unlimitedStock: product.unlimitedStock,
        hideInEMenu: product.hideInEMenu,
        productLocation: product.productLocation,
        imageUrls: product.imageUrls,
        isActive: product.isActive,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      final database = await _databaseService.database;
      final id = await database.productDao.insertProduct(entity);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateProduct(ProductModel product) async {
    try {
      final entity = ProductEntity.fromDateTime(
        id: product.id,
        storeId: product.storeId,
        productCode: product.productCode,
        name: product.name,
        productSubname: product.productSubname,
        description: product.description,
        price: product.price,
        cost: product.cost,
        discountType: product.discountType,
        discount: product.discount,
        stockQuantity: product.stockQuantity,
        minStockLevel: product.minStockLevel,
        category: product.category,
        categoryId: product.categoryId,
        barcode: product.barcode,
        barcodeType: product.barcodeType,
        customBarcodeId: product.customBarcodeId,
        hideInEcommerce: product.hideInEcommerce,
        nonVat: product.nonVat,
        unlimitedStock: product.unlimitedStock,
        hideInEMenu: product.hideInEMenu,
        productLocation: product.productLocation,
        imageUrls: product.imageUrls,
        isActive: product.isActive,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      final database = await _databaseService.database;
      final result = await database.productDao.updateProduct(entity);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> deleteProduct(ProductModel product) async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      if (product.id == null) {
        return Left(DatabaseFailure('Product has no id'));
      }
      final existing =
          await database.productDao.getProductById(storeId, product.id!);
      if (existing == null) {
        return Left(DatabaseFailure('Product not found'));
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final remoteId = existing.remoteId;
      if (remoteId != null && remoteId.isNotEmpty) {
        await database.productDao.updateProduct(
          existing.copyWith(
            syncStatus: SyncStatus.pendingDelete,
            isActive: false,
            updatedAt: now,
          ),
        );
        return const Right(1);
      }
      await database.productDao.deleteProduct(existing);
      return const Right(1);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateStockQuantity(
      int id, int newQuantity) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final database = await _databaseService.database;
      final result =
          await database.productDao.updateStockQuantity(id, newQuantity, now);
      return Right(result ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateProductStatus(
      int id, bool isActive) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final database = await _databaseService.database;
      final result =
          await database.productDao.updateProductStatus(id, isActive, now);
      return Right(result ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveProductCount() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final count = await database.productDao.getActiveProductCountByStore(storeId);
      return Right(count ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getLowStockProductCount() async {
    try {
      final storeId = await _storeId();
      final database = await _databaseService.database;
      final count = await database.productDao.getLowStockProductCountByStore(storeId);
      return Right(count ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
