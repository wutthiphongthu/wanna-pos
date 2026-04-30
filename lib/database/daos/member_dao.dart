import 'package:floor/floor.dart';
import '../entities/member_entity.dart';

@dao
abstract class MemberDao {
  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND sync_status != 2 ORDER BY name ASC')
  Future<List<MemberEntity>> getAllMembersByStore(int storeId);

  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND isActive = 1 AND sync_status != 2 ORDER BY name ASC')
  Future<List<MemberEntity>> getActiveMembersByStore(int storeId);

  @Query('SELECT * FROM members WHERE store_id = :storeId AND id = :id')
  Future<MemberEntity?> getMemberById(int storeId, int id);

  @Query('SELECT * FROM members WHERE store_id = :storeId AND memberCode = :code')
  Future<MemberEntity?> getMemberByCode(int storeId, String code);

  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND sync_status != 2 AND (name LIKE :term OR memberCode LIKE :term OR phone LIKE :term OR email LIKE :term) ORDER BY name ASC')
  Future<List<MemberEntity>> searchMembersByStore(int storeId, String term);

  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND remote_id = :remoteId')
  Future<MemberEntity?> getMemberByRemoteId(int storeId, String remoteId);

  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND sync_status = 1')
  Future<List<MemberEntity>> getDirtyMembersByStore(int storeId);

  @Query(
      'SELECT * FROM members WHERE store_id = :storeId AND sync_status = 2')
  Future<List<MemberEntity>> getPendingDeleteMembersByStore(int storeId);

  @insert
  Future<int> insertMember(MemberEntity member);

  @update
  Future<int> updateMember(MemberEntity member);

  @delete
  Future<int> deleteMember(MemberEntity member);

  @Query(
      'UPDATE members SET points = :points, updated_at = :updatedAt, sync_status = 1 WHERE id = :id')
  Future<int?> updatePoints(int id, int points, int updatedAt);
}
