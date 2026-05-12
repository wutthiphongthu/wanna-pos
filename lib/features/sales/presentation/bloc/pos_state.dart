part of 'pos_bloc.dart';

class CartItem {
  final ProductModel product;
  final int quantity;
  /// ส่วนลดต่อรายการ (บาท)
  final double itemDiscount;

  const CartItem({
    required this.product,
    required this.quantity,
    this.itemDiscount = 0,
  });

  double get subtotal => product.price * quantity;
  double get subtotalAfterDiscount => (subtotal - itemDiscount).clamp(0.0, double.infinity);

  CartItem copyWith({int? quantity, double? itemDiscount}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        itemDiscount: itemDiscount ?? this.itemDiscount,
      );
}

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}

class PosCartLoaded extends PosState {
  final List<CartItem> items;
  final MemberModel? selectedMember;
  final int earnedPoints;
  /// ส่วนลดทั้งบิล (บาท)
  final double billDiscount;
  /// ข้อความเมื่อบันทึกบิลล้มเหลว (แสดง SnackBar แล้วให้ clear ด้วย [ClearPaymentError])
  final String? paymentErrorMessage;

  const PosCartLoaded({
    required this.items,
    this.selectedMember,
    this.earnedPoints = 0,
    this.billDiscount = 0,
    this.paymentErrorMessage,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// ยอดรวมก่อนหักส่วนลดทั้งบิล (หลังหักส่วนลดรายการแล้ว)
  double get subtotalAfterItemDiscounts =>
      items.fold(0.0, (sum, i) => sum + i.subtotalAfterDiscount);

  /// ยอดรวมสุทธิ (หลังหักส่วนลดรายการและส่วนลดทั้งบิล)
  double get total =>
      (subtotalAfterItemDiscounts - billDiscount).clamp(0.0, double.infinity);

  PosCartLoaded copyWith({
    List<CartItem>? items,
    MemberModel? selectedMember,
    int? earnedPoints,
    double? billDiscount,
    String? paymentErrorMessage,
    bool clearMember = false,
    bool clearPaymentError = false,
  }) =>
      PosCartLoaded(
        items: items ?? this.items,
        selectedMember: clearMember ? null : (selectedMember ?? this.selectedMember),
        earnedPoints: earnedPoints ?? this.earnedPoints,
        billDiscount: billDiscount ?? this.billDiscount,
        paymentErrorMessage: clearPaymentError
            ? null
            : (paymentErrorMessage ?? this.paymentErrorMessage),
      );

  @override
  List<Object?> get props =>
      [items, selectedMember, earnedPoints, billDiscount, paymentErrorMessage];
}
