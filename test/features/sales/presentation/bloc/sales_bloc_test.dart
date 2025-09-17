import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ppos/core/error/failures.dart';
import 'package:ppos/core/usecase/usecase.dart';
import 'package:ppos/features/sales/domain/entities/sale.dart';
import 'package:ppos/features/sales/domain/repositories/sales_repository.dart';
import 'package:ppos/features/sales/domain/usecases/get_sales.dart';
import 'package:ppos/features/sales/presentation/bloc/sales_bloc.dart';

// Simple mock implementations for testing
class MockSalesRepository implements SalesRepository {
  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String id) async {
    return const Left(DatabaseFailure('Sale not found'));
  }

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    return Right(sale);
  }

  @override
  Future<Either<Failure, Sale>> updateSale(Sale sale) async {
    return Right(sale);
  }

  @override
  Future<Either<Failure, bool>> deleteSale(String id) async {
    return const Right(true);
  }
}

class MockGetSales implements GetSales {
  @override
  Future<Either<Failure, List<Sale>>> call(NoParams params) async {
    return const Right([]);
  }

  @override
  get repository => MockSalesRepository();
}

void main() {
  late SalesBloc salesBloc;
  late MockGetSales mockGetSales;

  setUp(() {
    mockGetSales = MockGetSales();
    salesBloc = SalesBloc(getSales: mockGetSales);
  });

  tearDown(() {
    salesBloc.close();
  });

  test('initial state should be SalesInitial', () {
    expect(salesBloc.state, SalesInitial());
  });

  test('should emit SalesLoading then SalesLoaded when LoadSales is successful',
      () async {
    // Arrange
    final expectedStates = [
      SalesLoading(),
      const SalesLoaded(sales: []),
    ];

    // Act & Assert
    expectLater(salesBloc.stream, emitsInOrder(expectedStates));

    salesBloc.add(const LoadSales());
  });
}
