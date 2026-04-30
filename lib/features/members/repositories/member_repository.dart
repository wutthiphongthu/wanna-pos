import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../database/database_service.dart';
import '../../../database/entities/member_entity.dart';
import '../../../features/auth/services/auth_service_interface.dart';
import '../models/member_model.dart';

abstract class MemberRepository {
  Future<Either<Failure, List<MemberModel>>> getAllMembers();
  Future<Either<Failure, List<MemberModel>>> getActiveMembers();
  Future<Either<Failure, MemberModel?>> getMemberById(int id);
  Future<Either<Failure, MemberModel?>> getMemberByCode(String code);
  Future<Either<Failure, List<MemberModel>>> searchMembers(String term);
  Future<Either<Failure, int>> insertMember(MemberModel member);
  Future<Either<Failure, int>> updateMember(MemberModel member);
  Future<Either<Failure, int>> deleteMember(MemberModel member);
  Future<Either<Failure, int>> updatePoints(int id, int points);
  Future<Either<Failure, int>> addPoints(int id, int delta);
}

@LazySingleton(as: MemberRepository)
class MemberRepositoryImpl implements MemberRepository {
  final DatabaseService _databaseService;
  final IAuthService _authService;

  MemberRepositoryImpl(this._databaseService, this._authService);

  Future<int> _storeId() => _authService.getCurrentStoreId();

  MemberEntity _toEntity(MemberModel m) {
    return MemberEntity(
      id: m.id,
      storeId: m.storeId,
      memberCode: m.memberCode,
      name: m.name,
      email: m.email,
      phone: m.phone,
      membershipLevel: m.membershipLevel,
      points: m.points,
      isActive: m.isActive,
      createdAt: m.createdAt.millisecondsSinceEpoch,
      updatedAt: m.updatedAt.millisecondsSinceEpoch,
    );
  }

  @override
  Future<Either<Failure, List<MemberModel>>> getAllMembers() async {
    try {
      final storeId = await _storeId();
      final db = await _databaseService.database;
      final list = await db.memberDao.getAllMembersByStore(storeId);
      return Right(list.map((e) => MemberModel.fromEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberModel>>> getActiveMembers() async {
    try {
      final storeId = await _storeId();
      final db = await _databaseService.database;
      final list = await db.memberDao.getActiveMembersByStore(storeId);
      return Right(list.map((e) => MemberModel.fromEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberModel?>> getMemberById(int id) async {
    try {
      final storeId = await _storeId();
      final db = await _databaseService.database;
      final e = await db.memberDao.getMemberById(storeId, id);
      return Right(e != null ? MemberModel.fromEntity(e) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberModel?>> getMemberByCode(String code) async {
    try {
      final storeId = await _storeId();
      final db = await _databaseService.database;
      final e = await db.memberDao.getMemberByCode(storeId, code);
      return Right(e != null ? MemberModel.fromEntity(e) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberModel>>> searchMembers(String term) async {
    try {
      final storeId = await _storeId();
      final db = await _databaseService.database;
      final list = await db.memberDao.searchMembersByStore(storeId, '%$term%');
      return Right(list.map((e) => MemberModel.fromEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> insertMember(MemberModel member) async {
    try {
      final storeId = await _storeId();
      final now = DateTime.now();
      final m = member.copyWith(storeId: storeId, createdAt: now, updatedAt: now);
      final db = await _databaseService.database;
      return Right(await db.memberDao.insertMember(_toEntity(m)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateMember(MemberModel member) async {
    try {
      final now = DateTime.now();
      final m = member.copyWith(updatedAt: now);
      final db = await _databaseService.database;
      return Right(await db.memberDao.updateMember(_toEntity(m)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> deleteMember(MemberModel member) async {
    try {
      final db = await _databaseService.database;
      final entity = _toEntity(member);
      if (entity.id == null) return Left(DatabaseFailure('Member has no id'));
      return Right(await db.memberDao.deleteMember(entity));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updatePoints(int id, int points) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      return Right(await db.memberDao.updatePoints(id, points, now) ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> addPoints(int id, int delta) async {
    final result = await getMemberById(id);
    return result.fold(
      (f) => Left(f),
      (m) async {
        if (m == null) return Left(DatabaseFailure('Member not found'));
        final newPoints = m.points + delta;
        if (newPoints < 0) return Left(DatabaseFailure('คะแนนไม่เพียงพอ'));
        return updatePoints(id, newPoints);
      },
    );
  }
}
