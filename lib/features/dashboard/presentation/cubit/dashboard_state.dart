part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSalesSummary today;
  final DashboardSalesSummary yesterday;
  final List<SaleEntity> latestSales;

  const DashboardLoaded({
    required this.today,
    required this.yesterday,
    this.latestSales = const [],
  });

  /// การเติบโต % เทียบเมื่อวาน (ถ้าเมื่อวาน 0 แล้ววันนี้มีค่า = 100)
  double get growthPercent {
    if (yesterday.totalAmount <= 0) {
      return today.totalAmount > 0 ? 100 : 0;
    }
    return ((today.totalAmount - yesterday.totalAmount) / yesterday.totalAmount) * 100;
  }

  @override
  List<Object?> get props => [today, yesterday, latestSales];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
