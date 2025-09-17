import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../core/utils/constants.dart';
import 'entities/sale_entity.dart';
import 'entities/product_entity.dart';
import 'entities/category_entity.dart';
import 'daos/sale_dao.dart';
import 'daos/product_dao.dart';
import 'daos/category_dao.dart';

part 'app_database.g.dart';

@Database(
  version: AppConstants.databaseVersion,
  entities: [
    SaleEntity,
    ProductEntity,
    CategoryEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  SaleDao get saleDao;
  ProductDao get productDao;
  CategoryDao get categoryDao;
}
