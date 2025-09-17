import 'package:equatable/equatable.dart';

class LoyaltyCard extends Equatable {
  final String id;
  final String memberId;
  final String cardNumber;
  final int points;
  final String tier;
  final DateTime expiryDate;
  final bool isActive;

  const LoyaltyCard({
    required this.id,
    required this.memberId,
    required this.cardNumber,
    required this.points,
    required this.tier,
    required this.expiryDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        memberId,
        cardNumber,
        points,
        tier,
        expiryDate,
        isActive,
      ];
}
