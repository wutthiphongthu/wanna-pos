import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/pos_bloc.dart';
import 'member_selector_dialog.dart';

Color _primary(BuildContext context) => Theme.of(context).colorScheme.primary;
Color _primaryContainer(BuildContext context) =>
    Theme.of(context).colorScheme.primaryContainer;

String _paymentMethodLabelUi(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cash:
      return 'เงินสด';
    case PaymentMethod.transfer:
      return 'โอนเงิน';
    case PaymentMethod.mixed:
      return 'ผสม (หลายช่องทาง)';
  }
}

class _PaymentDialogResult {
  final PaymentMethod method;
  final double amountReceived;

  _PaymentDialogResult({required this.method, required this.amountReceived});
}

Future<_PaymentDialogResult?> _showPaymentMethodDialog(
  BuildContext context, {
  required double orderTotal,
}) {
  return showDialog<_PaymentDialogResult>(
    context: context,
    builder: (ctx) => _PaymentMethodDialog(
      orderTotal: orderTotal,
    ),
  );
}

/// Dialog สรุปรายการหลังกดตกลง: รับ, ทอน, ปุ่มพิมพ์ใบเสร็จ
Future<void> _showPaymentSummaryDialog(
  BuildContext context, {
  required double amountReceived,
  required double orderTotal,
  required PaymentMethod paymentMethod,
  int earnedPoints = 0,
  bool hasMember = false,
}) {
  final change =
      paymentMethod == PaymentMethod.cash && amountReceived >= orderTotal
          ? amountReceived - orderTotal
          : 0.0;

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('สรุปรายการชำระเงิน', style: TextStyle(fontSize: 22)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summaryTextRow('ช่องทาง', _paymentMethodLabelUi(paymentMethod)),
          const SizedBox(height: 8),
          _summaryRow('ยอดสุทธิ', orderTotal),
          const SizedBox(height: 8),
          _summaryRow('รับ', amountReceived),
          if (change > 0) ...[
            const SizedBox(height: 12),
            _summaryRow('ทอน', change, isChange: true),
          ],
          if (hasMember && earnedPoints > 0) ...[
            const SizedBox(height: 12),
            Text(
              'สะสม $earnedPoints คะแนนให้สมาชิก',
              style: TextStyle(fontSize: 18, color: Colors.green[700]),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ปิด', style: TextStyle(fontSize: 16)),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ฟังก์ชันพิมพ์ใบเสร็จจะเปิดใช้ในเวอร์ชันถัดไป'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.receipt_long, size: 22),
          label: const Text('พิมพ์ใบเสร็จ', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

Widget _summaryRow(String label, double amount, {bool isChange = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isChange ? Colors.green[700] : null,
        ),
      ),
      Text(
        NumberFormatter.formatCurrency(amount),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isChange ? Colors.green[700] : null,
        ),
      ),
    ],
  );
}

Widget _summaryTextRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

/// Dialog เลือกช่องทางชำระ + กรอกจำนวนเงินที่รับมา (แป้นตัวเลข)
class _PaymentMethodDialog extends StatefulWidget {
  final double orderTotal;

  const _PaymentMethodDialog({required this.orderTotal});

  @override
  State<_PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  late PaymentMethod _method;
  final StringBuffer _amountBuffer = StringBuffer();

  @override
  void initState() {
    super.initState();
    _method = PaymentMethod.cash;
  }

  double get _currentAmount {
    final s = _amountBuffer.toString().trim();
    if (s.isEmpty) return 0;
    return double.tryParse(s) ?? 0;
  }

  String? _validateForConfirm() {
    final total = widget.orderTotal;
    if (total <= 0) return 'ยอดสุทธิไม่ถูกต้อง';
    final received = _currentAmount;
    if (received.isNaN || received.isInfinite) return 'จำนวนเงินไม่ถูกต้อง';
    if (received < 0) return 'จำนวนเงินต้องไม่ติดลบ';
    const eps = 0.009;
    if (received + eps < total) {
      return 'ยอดที่รับมา (${NumberFormatter.formatCurrency(received)}) '
          'ต้องไม่น้อยกว่ายอดสุทธิ (${NumberFormatter.formatCurrency(total)})';
    }
    return null;
  }

  void _fillBufferWithOrderTotalExact() {
    _amountBuffer.clear();
    final t = widget.orderTotal;
    if ((t - t.round()).abs() < 1e-6) {
      _amountBuffer.write(t.round().toString());
    } else {
      _amountBuffer.write(t.toStringAsFixed(2));
    }
  }

  void _setTotalExact() {
    setState(_fillBufferWithOrderTotalExact);
  }

  void _onKey(String key) {
    setState(() {
      if (key == 'backspace') {
        final str = _amountBuffer.toString();
        _amountBuffer.clear();
        if (str.isNotEmpty) {
          _amountBuffer.write(str.substring(0, str.length - 1));
        }
        return;
      }
      if (key == 'C') {
        _amountBuffer.clear();
        return;
      }
      if (key == '.' && _amountBuffer.toString().contains('.')) return;
      if (_amountBuffer.length >= 15) return;
      _amountBuffer.write(key);
    });
  }

  void _addAmount(double amount) {
    setState(() {
      final now = _currentAmount;
      _amountBuffer.clear();
      _amountBuffer.write((now + amount).toStringAsFixed(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount =
        _amountBuffer.isEmpty ? '0' : _amountBuffer.toString();
    final lockAmountInput = _method == PaymentMethod.transfer;

    return ScaffoldMessenger(
      child: Builder(
        builder: (messengerContext) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: AlertDialog(
              title: const Text('ช่องทางการชำระเงิน'),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text('ช่องทาง',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                _methodChip(PaymentMethod.cash,
                                    Icons.payments_outlined, 'เงินสด'),
                                const SizedBox(width: 4),
                                _methodChip(PaymentMethod.transfer,
                                    Icons.account_balance_outlined, 'โอน'),
                                const SizedBox(width: 4),
                                _methodChip(PaymentMethod.mixed,
                                    Icons.call_split, 'ผสม'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primary(context).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _primary(context).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long,
                                color: _primary(context), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ยอดสุทธิที่ต้องชำระ',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    NumberFormatter.formatCurrency(
                                        widget.orderTotal),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _primary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('จำนวนเงินที่รับมา (บาท)',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: lockAmountInput ? null : _setTotalExact,
                            style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: const Text('ใช้ยอดรวม',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayAmount.isEmpty ? '0' : displayAmount,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace'),
                        ),
                      ),
                      if (widget.orderTotal > 0 &&
                          _method == PaymentMethod.cash &&
                          !_currentAmount.isNaN &&
                          _currentAmount + 0.009 >= widget.orderTotal)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'เงินทอน ${NumberFormatter.formatCurrency(_currentAmount - widget.orderTotal)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      if (_method == PaymentMethod.transfer)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'โอนเงิน: ยอดรับเท่ายอดสุทธิ (ไม่สามารถแก้ไขตัวเลขได้)',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[700]),
                          ),
                        ),
                      if (_method == PaymentMethod.mixed)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'ผสม: กรอกยอดรับรวมจากทุกช่องทาง (ต้องไม่น้อยกว่ายอดสุทธิ)',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[700]),
                          ),
                        ),
                      const SizedBox(height: 10),
                      AbsorbPointer(
                        absorbing: lockAmountInput,
                        child: Opacity(
                          opacity: lockAmountInput ? 0.45 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildNumberPad()),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 88, child: _buildQuickAddButtons()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(messengerContext),
                  child: const Text('ยกเลิก'),
                ),
                FilledButton(
                  onPressed: () {
                    final err = _validateForConfirm();
                    if (err != null) {
                      ScaffoldMessenger.of(messengerContext).showSnackBar(
                        SnackBar(
                          content: Text(err),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(
                      messengerContext,
                      _PaymentDialogResult(
                        method: _method,
                        amountReceived: _currentAmount,
                      ),
                    );
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _methodChip(PaymentMethod value, IconData icon, String label) {
    final selected = _method == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _method = value;
            if (value == PaymentMethod.transfer) {
              _fillBufferWithOrderTotalExact();
            }
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? _primary(context).withValues(alpha: 0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: selected ? _primary(context) : Colors.transparent,
                width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? _primary(context) : Colors.grey[700]),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  static const double _kNumKeyHeight = 64;
  static const double _kQuickAddKeyHeight = 64;

  Widget _buildQuickAddButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _quickAddKey(50),
        const SizedBox(height: 4),
        _quickAddKey(100),
        const SizedBox(height: 4),
        _quickAddKey(500),
        const SizedBox(height: 4),
        _quickAddKey(1000),
      ],
    );
  }

  Widget _quickAddKey(double amount) {
    return SizedBox(
      height: _kQuickAddKeyHeight,
      child: Material(
        color: _primary(context).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _addAmount(amount),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              '+${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _primary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _kNumKeyHeight,
          child: Row(
            children: ['7', '8', '9'].map((k) => _numKey(k)).toList(),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _kNumKeyHeight,
          child: Row(
            children: ['4', '5', '6'].map((k) => _numKey(k)).toList(),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _kNumKeyHeight,
          child: Row(
            children: ['1', '2', '3'].map((k) => _numKey(k)).toList(),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _kNumKeyHeight,
          child: Row(
            children: [
              _numKey('0'),
              _numKey('.'),
              _actionKey('backspace', Icons.backspace_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _onKey(key),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(key,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionKey(String action, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _onKey(action),
            borderRadius: BorderRadius.circular(8),
            child: Center(child: Icon(icon, size: 26)),
          ),
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        final cartState = state is PosCartLoaded ? state : null;
        final items = cartState?.items ?? <CartItem>[];
        final itemCount = cartState?.itemCount ?? 0;
        final total = cartState?.total ?? 0.0;
        final subtotalAfterItems = cartState?.subtotalAfterItemDiscounts ?? 0.0;
        final billDiscount = cartState?.billDiscount ?? 0.0;
        final selectedMember = cartState?.selectedMember;
        final earnedPoints = cartState?.earnedPoints ?? 0;

        return Card(
          margin: const EdgeInsets.all(6),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryContainer(context).withValues(alpha: 0.3),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        color: _primary(context), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'ตะกร้า',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$itemCount รายการ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      NumberFormatter.formatCurrency(total),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ยังไม่มีสินค้าในตะกร้า',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return OrderItemCard(
                            item: item,
                            index: index,
                            onRemove: () => context
                                .read<PosBloc>()
                                .add(RemoveFromCart(item.product.id!)),
                            onQuantityChanged: (qty) =>
                                context.read<PosBloc>().add(
                                      UpdateCartQuantity(
                                        item.product.id!,
                                        qty,
                                      ),
                                    ),
                            onItemDiscount: (amount) => context
                                .read<PosBloc>()
                                .add(SetItemDiscount(item.product.id!, amount)),
                          );
                        },
                      ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  children: [
                    // แสดงลูกค้าเสมอ (ไม่ต้องมีสินค้าในตะกร้าก่อน)
                    if (selectedMember != null) ...[
                      Row(
                        children: [
                          Icon(Icons.person,
                              size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${selectedMember.name} • +$earnedPoints คะแนน',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<PosBloc>().add(SelectMember(null)),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('เปลี่ยน',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ] else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            final m = await MemberSelectorDialog.show(context,
                                current: selectedMember);
                            if (context.mounted && m != null) {
                              context.read<PosBloc>().add(SelectMember(m));
                            }
                          },
                          icon: Icon(Icons.person_add_outlined,
                              size: 16, color: AppTheme.primaryColor),
                          label: Text(
                            'เลือกสมาชิก',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.primaryColor),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ยอดรวม (หลังส่วนลดรายการ)',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                          Text(
                            NumberFormatter.formatCurrency(subtotalAfterItems),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      _BillDiscountRow(
                        amount: billDiscount,
                        onChanged: (val) =>
                            context.read<PosBloc>().add(SetBillDiscount(val)),
                      ),
                      if (billDiscount > 0) const SizedBox(height: 2),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'รวมสุทธิ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatCurrency(total),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (items.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('ยืนยันการเคลียร์'),
                                  content: const Text(
                                    'คุณต้องการเคลียร์สินค้าทั้งหมดในตะกร้าหรือไม่?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('เคลียร์'),
                                    ),
                                  ],
                                ),
                              ).then((ok) {
                                if (ok == true && context.mounted) {
                                  context
                                      .read<PosBloc>()
                                      .add(const ClearCart());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('เคลียร์ตะกร้าเรียบร้อยแล้ว'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              });
                            },
                            icon: Icon(Icons.delete_outline,
                                size: 16, color: Colors.red[700]),
                            label: const Text('เคลียร์ตะกร้า',
                                style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[700],
                            ),
                          ),
                        if (items.isNotEmpty) const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: items.isEmpty
                                  ? null
                                  : () async {
                                      final result =
                                          await _showPaymentMethodDialog(
                                        context,
                                        orderTotal: total,
                                      );
                                      if (!context.mounted || result == null) {
                                        return;
                                      }
                                      final bloc = context.read<PosBloc>();
                                      bloc.add(ProcessPayment(
                                          paymentMethod: result.method,
                                          amountReceived:
                                              result.amountReceived));
                                      try {
                                        final next = await bloc.stream
                                            .timeout(
                                          const Duration(seconds: 45),
                                        )
                                            .firstWhere(
                                          (s) {
                                            if (s is PosInitial) return true;
                                            if (s is PosCartLoaded &&
                                                s.paymentErrorMessage != null) {
                                              return true;
                                            }
                                            return false;
                                          },
                                        );
                                        if (!context.mounted) return;
                                        if (next is PosInitial) {
                                          await _showPaymentSummaryDialog(
                                            context,
                                            amountReceived:
                                                result.amountReceived,
                                            orderTotal: total,
                                            paymentMethod: result.method,
                                            earnedPoints: earnedPoints,
                                            hasMember: selectedMember != null,
                                          );
                                        } else if (next is PosCartLoaded) {
                                          final msg = next.paymentErrorMessage;
                                          if (msg != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(msg),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                            bloc.add(const ClearPaymentError());
                                          }
                                        }
                                      } on TimeoutException {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'หมดเวลารอผลชำระเงิน กรุณาลองอีกครั้ง'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary(context),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ชำระเงิน (F12)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ความกว้างปุ่มลบที่โผล่เมื่อปัดซ้าย
const double _kDeleteButtonWidth = 72;

/// รายการสินค้าในตะกร้า — ปัดซ้ายเพื่อแสดงปุ่มลบ แล้วกดปุ่มลบถึงลบรายการ
class OrderItemCard extends StatefulWidget {
  final CartItem item;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double>? onItemDiscount;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onQuantityChanged,
    this.onItemDiscount,
  });

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  double _slideOffset = 0;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.item.itemDiscount > 0;
    final isEven = widget.index.isEven;
    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ปุ่มลบ (โผล่เมื่อปัดซ้าย) — กดแล้วถึงลบ
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: _kDeleteButtonWidth,
            child: Material(
              color: Colors.red[400],
              child: InkWell(
                onTap: widget.onRemove,
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // เนื้อหารายการ (ปัดซ้ายได้) — แถวเดียวกระชับ
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _slideOffset += d.delta.dx;
                  _slideOffset = _slideOffset.clamp(-_kDeleteButtonWidth, 0.0);
                });
              },
              onHorizontalDragEnd: (d) {
                setState(() {
                  if (d.primaryVelocity != null) {
                    if (d.primaryVelocity! < -100) {
                      _slideOffset = -_kDeleteButtonWidth;
                    } else if (d.primaryVelocity! > 100) {
                      _slideOffset = 0;
                    }
                  }
                  if (_slideOffset > -_kDeleteButtonWidth / 2) {
                    _slideOffset = 0;
                  } else {
                    _slideOffset = -_kDeleteButtonWidth;
                  }
                });
              },
              child: Transform.translate(
                offset: Offset(_slideOffset, 0),
                child: Container(
                  color: isEven ? Colors.white : Colors.grey[50],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // บรรทัดที่ 1: ชื่อสินค้า | ยอดรวม
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            NumberFormatter.formatCurrency(
                              hasDiscount
                                  ? widget.item.subtotalAfterDiscount
                                  : widget.item.subtotal,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 6),
                      // บรรทัดที่ 2: ราคา x จำนวน | ปุ่ม + -
                      Row(
                        children: [
                          Text(
                            '${NumberFormatter.formatCurrency(widget.item.product.price)} × ${widget.item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.remove,
                                size: 20, color: Colors.red[300]),
                            onPressed: () {
                              if (widget.item.quantity > 1) {
                                widget.onQuantityChanged(
                                    widget.item.quantity - 1);
                              } else {
                                widget.onRemove();
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${widget.item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add,
                                size: 20,
                                color:
                                    _primary(context).withValues(alpha: 0.9)),
                            onPressed: () => widget
                                .onQuantityChanged(widget.item.quantity + 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          if (widget.onItemDiscount != null)
                            InkWell(
                              onTap: () => _showItemDiscountDialog(
                                context,
                                item: widget.item,
                                onSave: widget.onItemDiscount!,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.discount_outlined,
                                  size: 18,
                                  color: hasDiscount
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showItemDiscountDialog(
    BuildContext context, {
    required CartItem item,
    required ValueChanged<double> onSave,
  }) {
    final controller = TextEditingController(
      text: item.itemDiscount > 0 ? item.itemDiscount.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ส่วนลดรายการ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.product.name,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'จำนวนส่วนลด (บาท)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              final val =
                  double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
              onSave(val.clamp(0.0, item.subtotal));
              Navigator.pop(ctx);
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

class _BillDiscountRow extends StatefulWidget {
  final double amount;
  final ValueChanged<double> onChanged;

  const _BillDiscountRow({required this.amount, required this.onChanged});

  @override
  State<_BillDiscountRow> createState() => _BillDiscountRowState();
}

class _BillDiscountRowState extends State<_BillDiscountRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _BillDiscountRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount &&
        _controller.text != widget.amount.toStringAsFixed(0)) {
      _controller.text =
          widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ส่วนลดทั้งบิล',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              suffixText: '฿',
            ),
            onChanged: (v) {
              final val = double.tryParse(v.replaceAll(',', '')) ?? 0;
              widget.onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
