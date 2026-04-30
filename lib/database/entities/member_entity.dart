import 'package:floor/floor.dart';

@Entity(tableName: 'members')
class MemberEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'store_id')
  final int storeId;
  final String memberCode;
  final String name;
  final String? email;
  final String? phone;
  final String membershipLevel;
  final int points;
  final bool isActive;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'remote_id')
  final String? remoteId;

  @ColumnInfo(name: 'sync_status')
  final int syncStatus;

  MemberEntity({
    this.id,
    this.storeId = 1,
    required this.memberCode,
    required this.name,
    this.email,
    this.phone,
    required this.membershipLevel,
    this.points = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus = 0,
  });

  MemberEntity copyWith({
    int? id,
    int? storeId,
    String? memberCode,
    String? name,
    String? email,
    String? phone,
    String? membershipLevel,
    int? points,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    String? remoteId,
    int? syncStatus,
  }) {
    return MemberEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      memberCode: memberCode ?? this.memberCode,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
