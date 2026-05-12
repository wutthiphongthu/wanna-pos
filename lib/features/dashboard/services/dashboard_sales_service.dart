import 'package:injectable/injectable.dart';

import '../../auth/services/auth_service_interface.dart';
import '../../sales/data/sales_repository_interface.dart';
import '../../sales/services/sale_detail_dto.dart';
import '../../../database/entities/sale_entity.dart';

/// แยกยอด/จำนวนบิลตามช่องทางชำระ (ค่าใน DB เป็น cash / transfer / mixed)
class DashboardPaymentBreakdown {
  final int cashBills;
  final double cashAmount;
  final int transferBills;
  final double transferAmount;
  final int mixedBills;
  final double mixedAmount;
  final int otherBills;
  final double otherAmount;

  const DashboardPaymentBreakdown({
    this.cashBills = 0,
    this.cashAmount = 0,
    this.transferBills = 0,
    this.transferAmount = 0,
    this.mixedBills = 0,
    this.mixedAmount = 0,
    this.otherBills = 0,
    this.otherAmount = 0,
  });

  static DashboardPaymentBreakdown fromSales(Iterable<SaleEntity> sales) {
    var cb = 0, tb = 0, mb = 0, ob = 0;
    var ca = 0.0, ta = 0.0, ma = 0.0, oa = 0.0;
    for (final s in sales) {
      switch (s.paymentMethod.toLowerCase()) {
        case 'cash':
          cb++;
          ca += s.totalAmount;
          break;
        case 'transfer':
          tb++;
          ta += s.totalAmount;
          break;
        case 'mixed':
          mb++;
          ma += s.totalAmount;
          break;
        default:
          ob++;
          oa += s.totalAmount;
      }
    }
    return DashboardPaymentBreakdown(
      cashBills: cb,
      cashAmount: ca,
      transferBills: tb,
      transferAmount: ta,
      mixedBills: mb,
      mixedAmount: ma,
      otherBills: ob,
      otherAmount: oa,
    );
  }
}

/// สรุปยอดขายสำหรับ dashboard
class DashboardSalesSummary {
  final double totalAmount;
  final int billCount;
  final double averagePerBill;
  final DashboardPaymentBreakdown paymentBreakdown;

  const DashboardSalesSummary({
    required this.totalAmount,
    required this.billCount,
    this.averagePerBill = 0,
    this.paymentBreakdown = const DashboardPaymentBreakdown(),
  });
}

@injectable
class DashboardSalesService {
  final ISalesRepository _salesRepo;
  final IAuthService _authService;

  DashboardSalesService(this._salesRepo, this._authService);

  /// ยอดขายวันนี้ (ตาม timezone ของ device)
  Future<DashboardSalesSummary> getTodaySummary() async {
    final storeId = await _authService.getCurrentStoreId();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _getSummaryForRange(storeId, startOfDay, endOfDay);
  }

  /// ยอดขายเมื่อวาน (สำหรับคำนวณการเติบโต)
  Future<DashboardSalesSummary> getYesterdaySummary() async {
    final storeId = await _authService.getCurrentStoreId();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfYesterday = startOfYesterday.add(const Duration(days: 1));
    return _getSummaryForRange(storeId, startOfYesterday, endOfYesterday);
  }

  Future<DashboardSalesSummary> _getSummaryForRange(
    int storeId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await _salesRepo.getSalesByDateRange(storeId, start, end);
    return result.fold(
      (_) => const DashboardSalesSummary(
        totalAmount: 0,
        billCount: 0,
        paymentBreakdown: DashboardPaymentBreakdown(),
      ),
      (sales) {
        final total = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
        final count = sales.length;
        final avg = count > 0 ? total / count : 0.0;
        return DashboardSalesSummary(
          totalAmount: total,
          billCount: count,
          averagePerBill: avg,
          paymentBreakdown: DashboardPaymentBreakdown.fromSales(sales),
        );
      },
    );
  }

  /// บิลล่าสุด 20 รายการ
  Future<List<SaleEntity>> getLatestSales({int limit = 20}) async {
    final storeId = await _authService.getCurrentStoreId();
    final result = await _salesRepo.getLatestSales(storeId, limit);
    return result.fold((_) => <SaleEntity>[], (list) => list);
  }

  /// รายละเอียดบิล (หัวบิล + รายการสินค้า) โดยใช้ saleId (string)
  Future<SaleDetailDto?> getSaleDetailBySaleId(String saleId) async {
    final storeId = await _authService.getCurrentStoreId();
    final result = await _salesRepo.getSaleDetailBySaleId(storeId, saleId);
    return result.fold<SaleDetailDto?>((_) => null, (SaleDetailDto? d) => d);
  }

  /// ยกเลิกบิล (อัปเดต status เป็น cancelled)
  Future<void> cancelSale(SaleEntity sale) async {
    final result = await _salesRepo.cancelSale(sale);
    result.fold((_) => throw Exception('Failed to cancel sale'), (_) {});
  }
}
