import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/services/auth_service_interface.dart';
import '../../../loyalty/services/loyalty_points_config_service_interface.dart';
import '../../../members/models/member_model.dart';
import '../../../members/repositories/member_repository.dart';
import '../../../stock/models/product_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';
import '../../data/sales_repository_interface.dart';

part 'pos_event.dart';
part 'pos_state.dart';

@injectable
class PosBloc extends Bloc<PosEvent, PosState> {
  final ISalesRepository _salesRepo;
  final IAuthService _authService;
  final MemberRepository _memberRepository;
  final ILoyaltyPointsConfigService _loyaltyConfigService;

  PosBloc(
    this._salesRepo,
    this._authService,
    this._memberRepository,
    this._loyaltyConfigService,
  ) : super(PosInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
    on<SelectMember>(_onSelectMember);
    on<SetItemDiscount>(_onSetItemDiscount);
    on<SetBillDiscount>(_onSetBillDiscount);
    on<ProcessPayment>(_onProcessPayment);
  }

  /// คำนวณคะแนนจากยอดสุดท้ายหลังหักส่วนลดรายการและส่วนลดทั้งบิล
  Future<int> _computeEarnedPoints(
    List<CartItem> items,
    MemberModel? member,
    double billDiscount,
  ) async {
    if (items.isEmpty) return 0;
    final config = await _loyaltyConfigService.getConfig();
    final subtotalAfterItemDiscounts =
        items.fold(0.0, (sum, i) => sum + i.subtotalAfterDiscount);
    final total =
        (subtotalAfterItemDiscounts - billDiscount).clamp(0.0, double.infinity);
    if (total <= 0) return 0;

    final eligibleSubtotal = items
        .where((i) => config.isCategoryEligible(i.product.category))
        .fold(0.0, (sum, i) => sum + i.subtotalAfterDiscount);
    if (eligibleSubtotal <= 0 || subtotalAfterItemDiscounts <= 0) return 0;

    // เฉพาะส่วนที่ eligible ได้รับสัดส่วนจากยอดสุดท้าย
    final eligibleTotal =
        total * (eligibleSubtotal / subtotalAfterItemDiscounts);
    final mult = AppConstants.membershipPointMultiplier[
            member?.membershipLevel ?? 'Bronze'] ??
        1.0;
    return (eligibleTotal / config.pointsPerBaht * mult).floor();
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    final currentItems = currentState?.items ?? <CartItem>[];
    final currentMember = currentState?.selectedMember;
    final productId = event.product.id;
    if (productId == null) return;

    final existingIndex =
        currentItems.indexWhere((i) => i.product.id == productId);
    final newItems = List<CartItem>.from(currentItems);

    if (existingIndex >= 0) {
      newItems[existingIndex] = newItems[existingIndex]
          .copyWith(quantity: newItems[existingIndex].quantity + event.quantity);
    } else {
      newItems.add(CartItem(product: event.product, quantity: event.quantity));
    }

    final billDiscount = currentState?.billDiscount ?? 0;
    final pts = await _computeEarnedPoints(newItems, currentMember, billDiscount);
    emit(PosCartLoaded(
      items: newItems,
      selectedMember: currentMember,
      earnedPoints: pts,
      billDiscount: billDiscount,
    ));
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    final currentItems = currentState?.items ?? <CartItem>[];
    final currentMember = currentState?.selectedMember;
    final newItems =
        currentItems.where((i) => i.product.id != event.productId).toList();

    if (newItems.isEmpty) {
      emit(PosInitial());
    } else {
      final billDiscount = currentState?.billDiscount ?? 0;
      final pts =
          await _computeEarnedPoints(newItems, currentMember, billDiscount);
      emit(PosCartLoaded(
        items: newItems,
        selectedMember: currentMember,
        earnedPoints: pts,
        billDiscount: billDiscount,
      ));
    }
  }

  Future<void> _onUpdateCartQuantity(UpdateCartQuantity event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    final currentItems = currentState?.items ?? <CartItem>[];
    final currentMember = currentState?.selectedMember;
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.productId));
      return;
    }

    final index =
        currentItems.indexWhere((i) => i.product.id == event.productId);
    if (index < 0) return;

    final newItems = List<CartItem>.from(currentItems);
    newItems[index] = newItems[index].copyWith(quantity: event.quantity);
    final billDiscount = currentState?.billDiscount ?? 0;
    final pts =
        await _computeEarnedPoints(newItems, currentMember, billDiscount);
    emit(PosCartLoaded(
      items: newItems,
      selectedMember: currentMember,
      earnedPoints: pts,
      billDiscount: billDiscount,
    ));
  }

  Future<void> _onSetItemDiscount(
      SetItemDiscount event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    final currentItems = currentState?.items ?? [];
    final currentMember = currentState?.selectedMember;
    final amount = event.amount.clamp(0.0, double.infinity);
    final index = currentItems.indexWhere((i) => i.product.id == event.productId);
    if (index < 0) return;

    final newItems = List<CartItem>.from(currentItems);
    newItems[index] = newItems[index].copyWith(itemDiscount: amount);
    final billDiscount = currentState?.billDiscount ?? 0;
    final pts =
        await _computeEarnedPoints(newItems, currentMember, billDiscount);
    emit(PosCartLoaded(
      items: newItems,
      selectedMember: currentMember,
      earnedPoints: pts,
      billDiscount: billDiscount,
    ));
  }

  Future<void> _onSetBillDiscount(
      SetBillDiscount event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    if (currentState == null) return;
    final amount = event.amount.clamp(0.0, double.infinity);
    final pts = await _computeEarnedPoints(
        currentState.items, currentState.selectedMember, amount);
    emit(currentState.copyWith(billDiscount: amount, earnedPoints: pts));
  }

  void _onClearCart(ClearCart event, Emitter<PosState> emit) {
    emit(PosInitial());
  }

  Future<void> _onSelectMember(SelectMember event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    final currentItems = currentState?.items ?? <CartItem>[];
    final billDiscount = currentState?.billDiscount ?? 0;
    final pts =
        await _computeEarnedPoints(currentItems, event.member, billDiscount);
    if (currentItems.isEmpty) {
      emit(event.member != null
          ? PosCartLoaded(
              items: [],
              selectedMember: event.member,
              earnedPoints: pts,
              billDiscount: billDiscount,
            )
          : PosInitial());
    } else {
      emit(PosCartLoaded(
        items: currentItems,
        selectedMember: event.member,
        earnedPoints: pts,
        billDiscount: billDiscount,
      ));
    }
  }

  Future<void> _onProcessPayment(ProcessPayment event, Emitter<PosState> emit) async {
    final currentState = state is PosCartLoaded ? state as PosCartLoaded : null;
    if (currentState == null || currentState.items.isEmpty) return;

    final member = currentState.selectedMember;
    final pointsToAdd = currentState.earnedPoints;
    final storeId = await _authService.getCurrentStoreId();
    final now = DateTime.now();
    final saleId = 'S${now.millisecondsSinceEpoch}';
    final customerId = member?.id.toString() ?? '0';
    final customerName = member?.name ?? '';
    final paymentMethodStr = event.paymentMethod.name; // cash, transfer, mixed
    final total = currentState.total;
    final amountReceived = event.amountReceived ?? total;
    final changeAmount = (amountReceived - total).clamp(0.0, double.infinity);

    final sale = SaleEntity.fromDateTime(
      storeId: storeId,
      saleId: saleId,
      customerId: customerId,
      customerName: customerName,
      totalAmount: total,
      paymentMethod: paymentMethodStr,
      status: 'completed',
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      createdAt: now,
      updatedAt: now,
    );

    final lineItems = currentState.items.map((item) {
      final productId = item.product.id;
      if (productId == null) return null;
      return SaleLineItemEntity(
        saleId: 0,
        productId: productId,
        productName: item.product.name,
        quantity: item.quantity,
        unitPrice: item.product.price,
        itemDiscount: item.itemDiscount,
        lineTotal: item.subtotalAfterDiscount,
      );
    }).whereType<SaleLineItemEntity>().toList();

    final createResult = await _salesRepo.createSaleWithLineItems(sale, lineItems);
    if (createResult.isLeft()) return;

    if (member != null && member.id != null && pointsToAdd > 0) {
      final ptsResult = await _memberRepository.addPoints(member.id!, pointsToAdd);
      ptsResult.fold((_) => {}, (_) => {});
    }

    emit(PosInitial());
  }
}
