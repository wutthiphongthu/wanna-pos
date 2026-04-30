import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../core/utils/constants.dart';
import 'entities/sale_entity.dart';
import 'entities/sale_line_item_entity.dart';
import 'entities/product_entity.dart';
import 'entities/category_entity.dart';
import 'entities/member_entity.dart';
import 'entities/store_entity.dart';
import 'daos/sale_dao.dart';
import 'daos/sale_line_item_dao.dart';
import 'daos/product_dao.dart';
import 'daos/category_dao.dart';
import 'daos/member_dao.dart';
import 'daos/store_dao.dart';

part 'app_database.g.dart';

@Database(
  version: AppConstants.databaseVersion,
  entities: [
    SaleEntity,
    SaleLineItemEntity,
    ProductEntity,
    CategoryEntity,
    MemberEntity,
    StoreEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  SaleDao get saleDao;
  SaleLineItemDao get saleLineItemDao;
  ProductDao get productDao;
  CategoryDao get categoryDao;
  MemberDao get memberDao;
  StoreDao get storeDao;
}
