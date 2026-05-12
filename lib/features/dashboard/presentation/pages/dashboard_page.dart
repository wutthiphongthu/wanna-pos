import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/theme.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../services/dashboard_sales_service.dart';
import '../../../sales/services/sale_detail_dto.dart';
import '../cubit/dashboard_cubit.dart';

String salePaymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return 'เงินสด';
    case 'transfer':
      return 'โอนเงิน';
    case 'mixed':
      return 'ผสม';
    default:
      return method.trim().isEmpty ? '-' : method;
  }
}

class DashboardPage extends StatelessWidget {
  final VoidCallback? onMenuTap;
  /// ไปยังเมนูใน shell: 0=หน้าขาย, 1=หลังบ้าน, 2=แดชบอร์ด, 3=สต็อก, 4=CRM
  final ValueChanged<int>? onNavigateToIndex;

  const DashboardPage({
    super.key,
    this.onMenuTap,
    this.onNavigateToIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(onMenuTap: onMenuTap),
            Expanded(
              child: SingleChildScrollView(
                child: _buildLowerContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowerContent(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อร้านจาก Auth
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) => curr is AuthAuthenticated,
            builder: (context, state) {
              final storeName = state is AuthAuthenticated ? state.storeName : 'ร้าน';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.store, color: primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      storeName,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Sales Statistics Card (White)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: สรุปยอดขาย + ปุ่ม refresh
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.green[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'สรุปยอดขาย (จาก transaction)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => context.read<DashboardCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'โหลดใหม่',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Statistics Row (จาก transaction จริง)
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    final isLoading = state is DashboardLoading;
                    final loaded = state is DashboardLoaded;
                    final todayTotal = loaded ? state.today.totalAmount : 0.0;
                    final todayCount = loaded ? state.today.billCount : 0;
                    final todayAvg = loaded ? state.today.averagePerBill : 0.0;
                    final growth = loaded ? state.growthPercent : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildMainStatCard(
                                context,
                                'ยอดรวมวันนี้',
                                isLoading ? '...' : NumberFormatter.formatCurrency(todayTotal),
                                Icons.attach_money,
                                Theme.of(context).colorScheme.primary,
                                subtitle: 'ยอดขายรวมทั้งหมด',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildMainStatCard(
                                context,
                                'การเติบโต',
                                isLoading ? '...' : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%',
                                growth >= 0 ? Icons.trending_up : Icons.trending_down,
                                growth >= 0 ? Colors.green : Colors.red,
                                subtitle: 'เทียบกับวันก่อนหน้า',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryStatCard(
                                context,
                                'บิลขาย',
                                isLoading ? '...' : '$todayCount',
                                Icons.receipt,
                                Theme.of(context).colorScheme.primary,
                                subtitle: 'รายการขายสำเร็จ',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSecondaryStatCard(
                                context,
                                'เฉลี่ย/บิล',
                                isLoading ? '...' : NumberFormatter.formatCurrency(todayAvg),
                                Icons.analytics,
                                Colors.green,
                                subtitle: 'ยอดเฉลี่ยต่อบิล',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'ช่องทางชำระ (วันนี้)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTodayPaymentBreakdown(
                          context,
                          isLoading
                              ? const DashboardPaymentBreakdown()
                              : (loaded
                                  ? state.today.paymentBreakdown
                                  : const DashboardPaymentBreakdown()),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // บิลขายล่าสุด 20 รายการ
          _buildLatestBillsSection(context),
        ],
      ),
    );
  }

  Widget _buildLatestBillsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'บิลขายล่าสุด 20 รายการ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (prev, curr) => curr is DashboardLoaded || curr is DashboardLoading,
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final loaded = state is DashboardLoaded;
              final list = loaded ? state.latestSales : <SaleEntity>[];
              if (!loaded || list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      list.isEmpty ? 'ยังไม่มีบิลขาย' : 'กำลังโหลด...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sale = list[index];
                  final isCancelled = sale.status == 'cancelled';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    title: Text(
                      sale.saleId,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                        color: isCancelled ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.createdAtDateTime.toString().substring(0, 16),
                          style: TextStyle(
                            fontSize: 12,
                            color: isCancelled ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          salePaymentMethodLabel(sale.paymentMethod),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCancelled
                                ? Colors.grey
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormatter.formatCurrency(sale.totalAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isCancelled ? Colors.grey : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (isCancelled)
                          Text(
                            'ยกเลิกแล้ว',
                            style: TextStyle(fontSize: 11, color: Colors.red[700]),
                          ),
                      ],
                    ),
                    onTap: () => _openSaleDetailDialog(context, sale),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPaymentBreakdown(
    BuildContext context,
    DashboardPaymentBreakdown bd,
  ) {
    final other = bd.otherBills > 0 || bd.otherAmount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _paymentMiniTile(
                context,
                label: 'เงินสด',
                bills: bd.cashBills,
                amount: bd.cashAmount,
                icon: Icons.payments_outlined,
                accent: Colors.teal.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _paymentMiniTile(
                context,
                label: 'โอนเงิน',
                bills: bd.transferBills,
                amount: bd.transferAmount,
                icon: Icons.account_balance_outlined,
                accent: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _paymentMiniTile(
                context,
                label: 'ผสม',
                bills: bd.mixedBills,
                amount: bd.mixedAmount,
                icon: Icons.call_split,
                accent: Colors.deepPurple.shade700,
              ),
            ),
          ],
        ),
        if (other) ...[
          const SizedBox(height: 10),
          _paymentMiniTile(
            context,
            label: 'อื่นๆ',
            bills: bd.otherBills,
            amount: bd.otherAmount,
            icon: Icons.payment_outlined,
            accent: Colors.grey.shade700,
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _paymentMiniTile(
    BuildContext context, {
    required String label,
    required int bills,
    required double amount,
    required IconData icon,
    required Color accent,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            '$bills บิล',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _openSaleDetailDialog(BuildContext context, SaleEntity sale) async {
    final cubit = context.read<DashboardCubit>();
    final saleId = sale.saleId;
    if (saleId.isEmpty) return;
    final detail = await cubit.getSaleDetailBySaleId(saleId);
    if (!context.mounted || detail == null) return;
    showDialog(
      context: context,
      builder: (ctx) => _SaleDetailDialog(
        detail: detail,
        onCancelBill: () async {
          Navigator.of(ctx).pop();
          await cubit.cancelSale(sale);
          if (ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('ยกเลิกบิลเรียบร้อย'), behavior: SnackBarBehavior.floating),
            );
          }
        },
      ),
    );
  }

  Widget _buildMainStatCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatCard(BuildContext context, String title,
      String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const _DashboardHeader({this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => curr is AuthAuthenticated,
      builder: (context, state) {
        final storeName = state is AuthAuthenticated ? state.storeName : 'PPOS';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'แดชบอร์ด',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (storeName.isNotEmpty)
                      Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

/// Dialog แสดงรายละเอียดบิล: รายการสินค้า, ยอดรวม, ช่องทางชำระ, จำนวนที่ชำระ, เงินทอน, ปุ่มยกเลิกบิล
class _SaleDetailDialog extends StatelessWidget {
  final SaleDetailDto detail;
  final VoidCallback onCancelBill;

  const _SaleDetailDialog({required this.detail, required this.onCancelBill});

  @override
  Widget build(BuildContext context) {
    final sale = detail.sale;
    final lineItems = detail.lineItems;
    final isCancelled = sale.status == 'cancelled';
    final customerName = sale.customerName.trim().isEmpty ? 'ลูกค้าทั่วไป' : sale.customerName;
    final amountReceived = sale.amountReceived;
    final change = sale.changeAmount;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text('รายละเอียดบิล ${sale.saleId}'),
          ),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('ยกเลิกแล้ว', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600, fontSize: 12)),
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(label: 'ชื่อลูกค้า', value: customerName),
              const SizedBox(height: 12),
              Text(
                'รายการสินค้า',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              ...lineItems.map((item) => _LineItemRow(item: item)),
              const SizedBox(height: 20),
              const Divider(height: 1),
              _SummaryRow(label: 'ยอดรวม', value: NumberFormatter.formatCurrency(sale.totalAmount)),
              _SummaryRow(
                  label: 'ช่องทางชำระ',
                  value: salePaymentMethodLabel(sale.paymentMethod)),
              _SummaryRow(label: 'จำนวนที่ชำระ', value: NumberFormatter.formatCurrency(amountReceived)),
              _SummaryRow(label: 'เงินทอน', value: NumberFormatter.formatCurrency(change)),
              const SizedBox(height: 16),
              if (!isCancelled)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('ยกเลิกบิล'),
                          content: const Text('ต้องการยกเลิกบิลนี้ใช่หรือไม่?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('ไม่'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                onCancelBill();
                              },
                              child: Text('ยกเลิกบิล', style: TextStyle(color: Colors.red[700])),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text('ยกเลิกบิล'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final SaleLineItemEntity item;

  const _LineItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${item.quantity} x ${NumberFormatter.formatCurrency(item.unitPrice)}'
                  '${item.itemDiscount > 0 ? " ลด ${NumberFormatter.formatCurrency(item.itemDiscount)}" : ""}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            NumberFormatter.formatCurrency(item.lineTotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
