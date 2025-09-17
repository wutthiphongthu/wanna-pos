import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime joinDate;
  final String membershipLevel;
  final double points;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.membershipLevel,
    required this.points,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        joinDate,
        membershipLevel,
        points,
      ];
}
