import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/get_sales.dart';
import '../../../../core/usecase/usecase.dart';

part 'sales_event.dart';
part 'sales_state.dart';

@injectable
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSales getSales;

  SalesBloc({required this.getSales}) : super(SalesInitial()) {
    on<LoadSales>(_onLoadSales);
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SalesState> emit) async {
    emit(SalesLoading());

    final result = await getSales(NoParams());

    result.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }
}
