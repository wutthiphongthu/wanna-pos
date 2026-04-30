import 'package:floor/floor.dart';
import '../entities/store_entity.dart';

@dao
abstract class StoreDao {
  @Query('SELECT * FROM stores ORDER BY name ASC')
  Future<List<StoreEntity>> getAllStores();

  @Query('SELECT * FROM stores WHERE is_active = 1 ORDER BY name ASC')
  Future<List<StoreEntity>> getActiveStores();

  @Query('SELECT * FROM stores WHERE id = :id')
  Future<StoreEntity?> getStoreById(int id);

  @insert
  Future<int> insertStore(StoreEntity store);

  @update
  Future<int> updateStore(StoreEntity store);

  @delete
  Future<int> deleteStore(StoreEntity store);
}
