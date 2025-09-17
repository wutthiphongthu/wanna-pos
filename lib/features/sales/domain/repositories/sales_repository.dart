import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<Sale>>> getSales();
  Future<Either<Failure, Sale>> getSaleById(String id);
  Future<Either<Failure, Sale>> createSale(Sale sale);
  Future<Either<Failure, Sale>> updateSale(Sale sale);
  Future<Either<Failure, bool>> deleteSale(String id);
}
