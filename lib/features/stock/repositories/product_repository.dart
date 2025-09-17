import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../../database/database_service.dart';
import '../../../database/entities/product_entity.dart';
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

  ProductRepositoryImpl(this._databaseService);

  @override
  Future<Either<Failure, List<ProductModel>>> getAllProducts() async {
    try {
      final database = await _databaseService.database;
      final entities = await database.productDao.getAllProducts();
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getActiveProducts() async {
    try {
      final database = await _databaseService.database;
      final entities = await database.productDao.getActiveProducts();
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel?>> getProductById(int id) async {
    try {
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductById(id);
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
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductByCode(productCode);
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
      final database = await _databaseService.database;
      final entity = await database.productDao.getProductByBarcode(barcode);
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
      final database = await _databaseService.database;
      final entities =
          await database.productDao.searchProducts('%$searchTerm%');
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
      final database = await _databaseService.database;
      final entities =
          await database.productDao.getProductsByCategory(category);
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getLowStockProducts() async {
    try {
      final database = await _databaseService.database;
      final entities = await database.productDao.getLowStockProducts();
      final models = entities.map((e) => ProductModel.fromEntity(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    try {
      final database = await _databaseService.database;
      final categories = await database.productDao.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> insertProduct(ProductModel product) async {
    try {
      final entity = ProductEntity.fromDateTime(
        id: product.id,
        productCode: product.productCode,
        name: product.name,
        description: product.description,
        price: product.price,
        cost: product.cost,
        stockQuantity: product.stockQuantity,
        minStockLevel: product.minStockLevel,
        category: product.category,
        barcode: product.barcode,
        imageUrl: product.imageUrl,
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
        productCode: product.productCode,
        name: product.name,
        description: product.description,
        price: product.price,
        cost: product.cost,
        stockQuantity: product.stockQuantity,
        minStockLevel: product.minStockLevel,
        category: product.category,
        barcode: product.barcode,
        imageUrl: product.imageUrl,
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
      final entity = ProductEntity.fromDateTime(
        id: product.id,
        productCode: product.productCode,
        name: product.name,
        description: product.description,
        price: product.price,
        cost: product.cost,
        stockQuantity: product.stockQuantity,
        minStockLevel: product.minStockLevel,
        category: product.category,
        barcode: product.barcode,
        imageUrl: product.imageUrl,
        isActive: product.isActive,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );
      final database = await _databaseService.database;
      final result = await database.productDao.deleteProduct(entity);
      return Right(result);
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
      final database = await _databaseService.database;
      final count = await database.productDao.getActiveProductCount();
      return Right(count ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getLowStockProductCount() async {
    try {
      final database = await _databaseService.database;
      final count = await database.productDao.getLowStockProductCount();
      return Right(count ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
