part of 'pos_bloc.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends PosEvent {
  final ProductModel product;
  final int quantity;

  const AddToCart(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCart extends PosEvent {
  final int productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQuantity extends PosEvent {
  final int productId;
  final int quantity;

  const UpdateCartQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends PosEvent {
  const ClearCart();
}

class SelectMember extends PosEvent {
  final MemberModel? member;

  const SelectMember(this.member);

  @override
  List<Object?> get props => [member];
}

class SetItemDiscount extends PosEvent {
  final int productId;
  final double amount;

  const SetItemDiscount(this.productId, this.amount);

  @override
  List<Object?> get props => [productId, amount];
}

class SetBillDiscount extends PosEvent {
  final double amount;

  const SetBillDiscount(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// ช่องทางการชำระเงิน
enum PaymentMethod { cash, transfer, mixed }

class ProcessPayment extends PosEvent {
  final PaymentMethod paymentMethod;
  /// จำนวนที่ลูกค้าชำระ (ใช้คำนวณเงินทอน; ถ้าไม่ส่งใช้เท่ากับยอดรวม)
  final double? amountReceived;

  const ProcessPayment({required this.paymentMethod, this.amountReceived});

  @override
  List<Object?> get props => [paymentMethod, amountReceived];
}

class ClearPaymentError extends PosEvent {
  const ClearPaymentError();
}
