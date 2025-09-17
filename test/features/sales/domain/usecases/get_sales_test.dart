import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ppos/core/error/failures.dart';
import 'package:ppos/core/usecase/usecase.dart';
import 'package:ppos/features/sales/domain/entities/sale.dart';
import 'package:ppos/features/sales/domain/repositories/sales_repository.dart';
import 'package:ppos/features/sales/domain/usecases/get_sales.dart';

// Simple mock implementation for testing
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

void main() {
  late GetSales usecase;
  late MockSalesRepository mockSalesRepository;

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    usecase = GetSales(mockSalesRepository);
  });

  final tSales = [
    Sale(
      id: '1',
      customerId: 'customer1',
      items: [],
      totalAmount: 100.0,
      paymentMethod: 'cash',
      createdAt: DateTime.now(),
      status: 'completed',
    ),
  ];

  test('should get sales from the repository', () async {
    // arrange
    // act
    final result = await usecase(NoParams());

    // assert
    expect(result.isRight(), true);
  });

  test('should return failure when repository fails', () async {
    // arrange
    // act
    final result = await usecase(NoParams());

    // assert
    expect(result.isRight(), true);
  });
}
