import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../services/dashboard_sales_service.dart';
import '../../../sales/services/sale_detail_dto.dart';

part 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardSalesService _salesService;

  DashboardCubit(this._salesService) : super(DashboardInitial());

  Future<void> load() async {
    emit(DashboardLoading());
    try {
      final today = await _salesService.getTodaySummary();
      final yesterday = await _salesService.getYesterdaySummary();
      final latestSales = await _salesService.getLatestSales(limit: 20);
      emit(DashboardLoaded(
        today: today,
        yesterday: yesterday,
        latestSales: latestSales,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<SaleDetailDto?> getSaleDetailBySaleId(String saleId) async {
    return _salesService.getSaleDetailBySaleId(saleId);
  }

  /// ยกเลิกบิล แล้วโหลดข้อมูลใหม่
  Future<void> cancelSale(SaleEntity sale) async {
    await _salesService.cancelSale(sale);
    await load();
  }
}
