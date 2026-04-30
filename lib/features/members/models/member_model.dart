import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final int? id;
  final int storeId;
  final String memberCode;
  final String name;
  final String? email;
  final String? phone;
  final String membershipLevel;
  final int points;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemberModel({
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
  });

  factory MemberModel.fromEntity(dynamic entity) {
    return MemberModel(
      id: entity.id,
      storeId: entity.storeId ?? 1,
      memberCode: entity.memberCode,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      membershipLevel: entity.membershipLevel,
      points: entity.points ?? 0,
      isActive: entity.isActive ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAt),
    );
  }

  MemberModel copyWith({
    int? id,
    int? storeId,
    String? memberCode,
    String? name,
    String? email,
    String? phone,
    String? membershipLevel,
    int? points,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemberModel(
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
    );
  }

  @override
  List<Object?> get props =>
      [id, storeId, memberCode, name, email, phone, membershipLevel, points, isActive, createdAt, updatedAt];
}
