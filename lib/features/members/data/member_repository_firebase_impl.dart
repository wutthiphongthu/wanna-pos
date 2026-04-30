import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../auth/services/auth_service_interface.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

@injectable
class MemberRepositoryFirebaseImpl implements MemberRepository {
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MemberRepositoryFirebaseImpl(this._authService);

  Future<String> _storeId() async =>
      (await _authService.getCurrentStoreId()).toString();

  MemberModel _fromDoc(String docId, Map<String, dynamic> data) {
    return MemberModel(
      id: int.tryParse(docId),
      storeId: int.tryParse((data['storeId'] ?? '1').toString()) ?? 1,
      memberCode: (data['memberCode'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      email: data['email']?.toString(),
      phone: data['phone']?.toString(),
      membershipLevel: (data['membershipLevel'] ?? 'Bronze').toString(),
      points: (data['points'] ?? 0) is int
          ? (data['points'] ?? 0) as int
          : int.tryParse((data['points'] ?? '0').toString()) ?? 0,
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

  Map<String, dynamic> _toMap(MemberModel m) => {
        'storeId': m.storeId.toString(),
        'memberCode': m.memberCode,
        'name': m.name,
        'email': m.email,
        'phone': m.phone,
        'membershipLevel': m.membershipLevel,
        'points': m.points,
        'isActive': m.isActive,
        'createdAt': m.createdAt.millisecondsSinceEpoch,
        'updatedAt': m.updatedAt.millisecondsSinceEpoch,
      };

  @override
  Future<Either<Failure, List<MemberModel>>> getAllMembers() async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeMembers(storeId))
          .orderBy('name')
          .get();
      return Right(snap.docs.map((d) => _fromDoc(d.id, d.data())).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberModel>>> getActiveMembers() async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeMembers(storeId))
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      return Right(snap.docs.map((d) => _fromDoc(d.id, d.data())).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberModel?>> getMemberById(int id) async {
    try {
      final storeId = await _storeId();
      final doc = await _firestore
          .doc(FirestorePaths.storeMember(storeId, id.toString()))
          .get();
      if (!doc.exists || doc.data() == null) return Right(null);
      return Right(_fromDoc(doc.id, doc.data()!));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberModel?>> getMemberByCode(String code) async {
    try {
      final storeId = await _storeId();
      final snap = await _firestore
          .collection(FirestorePaths.storeMembers(storeId))
          .where('memberCode', isEqualTo: code)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return Right(null);
      return Right(_fromDoc(snap.docs.first.id, snap.docs.first.data()));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberModel>>> searchMembers(String term) async {
    try {
      final result = await getAllMembers();
      return result.fold(
        (f) => Left(f),
        (list) {
          final t = term.toLowerCase();
          final filtered = list
              .where((m) =>
                  m.name.toLowerCase().contains(t) ||
                  m.memberCode.toLowerCase().contains(t) ||
                  (m.phone?.toLowerCase().contains(t) ?? false) ||
                  (m.email?.toLowerCase().contains(t) ?? false))
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> insertMember(MemberModel member) async {
    try {
      final storeId = await _storeId();
      final id = member.id ?? DateTime.now().millisecondsSinceEpoch;
      final docId = id.toString();
      final now = DateTime.now();
      final m = member.copyWith(
        id: id,
        storeId: int.tryParse(storeId) ?? 1,
        createdAt: now,
        updatedAt: now,
      );
      final data = _toMap(m);
      data['createdAt'] = now.millisecondsSinceEpoch;
      data['updatedAt'] = now.millisecondsSinceEpoch;
      await _firestore
          .doc(FirestorePaths.storeMember(storeId, docId))
          .set(data);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updateMember(MemberModel member) async {
    try {
      if (member.id == null) return Left(DatabaseFailure('Member has no id'));
      final storeId = await _storeId();
      final now = DateTime.now();
      final m = member.copyWith(updatedAt: now);
      final data = _toMap(m);
      data['updatedAt'] = now.millisecondsSinceEpoch;
      await _firestore
          .doc(FirestorePaths.storeMember(storeId, member.id.toString()))
          .update(data);
      return Right(member.id!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> deleteMember(MemberModel member) async {
    try {
      if (member.id == null) return Left(DatabaseFailure('Member has no id'));
      final storeId = await _storeId();
      await _firestore
          .doc(FirestorePaths.storeMember(storeId, member.id.toString()))
          .delete();
      return Right(member.id!);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> updatePoints(int id, int points) async {
    try {
      final result = await getMemberById(id);
      return result.fold(
        (f) => Left(f),
        (m) async {
          if (m == null) return Left(DatabaseFailure('Member not found'));
          return updateMember(m.copyWith(points: points));
        },
      );
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
